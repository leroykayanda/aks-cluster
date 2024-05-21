# elk namespace

resource "kubernetes_namespace" "elk" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name = "elk"
  }
}

# elasticsearch

resource "helm_release" "elastic" {
  count      = var.cluster_created ? 1 : 0
  name       = "elasticsearch"
  chart      = "elasticsearch"
  version    = "8.5.1"
  repository = "https://helm.elastic.co"
  namespace  = "elk"

  set {
    name  = "replicas"
    value = var.elastic["replicas"]
  }

  set {
    name  = "minimumMasterNodes"
    value = var.elastic["minimumMasterNodes"]
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = var.elastic["pv_storage"]
  }

  set {
    name  = "createCert"
    value = "true"
  }

  set {
    name  = "protocol"
    value = "https"
  }

  set {
    name  = "secret.password"
    value = var.elastic_password
  }

  values = [
    <<EOF
    esConfig: 
      elasticsearch.yml: |
        xpack.security.enabled: true
    resources: 
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "1000m"
        memory: "2Gi"
    EOF
  ]

  depends_on = [
    kubernetes_namespace.elk
  ]

}

# kibana helm chart

resource "helm_release" "kibana" {
  count      = var.cluster_created ? 1 : 0
  name       = "kibana"
  chart      = "kibana"
  version    = "8.5.1"
  repository = "https://helm.elastic.co"
  namespace  = "elk"

  set {
    name  = "elasticsearchHosts"
    value = "https://elasticsearch-master.elk:9200"
  }

  set {
    name  = "automountToken"
    value = false
  }

  values = [
    <<EOF
    resources: 
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "1000m"
        memory: "2Gi"
    EOF
  ]

  depends_on = [
    helm_release.elastic
  ]

}

# kibana dns name

resource "azurerm_dns_a_record" "kibana" {
  count               = var.cluster_created ? 1 : 0
  name                = var.kibana["dns_name"]
  zone_name           = var.dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ip.id
}

# kibana tls secret

resource "kubernetes_secret" "kibana" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "tls-cert"
    namespace = "elk"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

# kibana ingress

resource "kubernetes_ingress_v1" "kibana" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "kibana"
    namespace = "elk"
    annotations = {
      "kubernetes.io/ingress.class"                                  = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/health-probe-unhealthy-threshold" = "2"
      "appgw.ingress.kubernetes.io/request-timeout"                  = "60"
      "appgw.ingress.kubernetes.io/ssl-redirect"                     = "true"
      "cert-manager.io/cluster-issuer"                               = "letsencrypt-issuer"
      "appgw.ingress.kubernetes.io/backend-protocol"                 = "HTTP"
    }
  }

  spec {
    tls {
      hosts       = ["${var.kibana["dns_name"]}.${var.dns_zone}"]
      secret_name = "tls-cert"
    }

    rule {
      host = "${var.kibana["dns_name"]}.${var.dns_zone}"

      http {
        path {
          path = "/"

          backend {
            service {
              name = "kibana-kibana"
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
  }

}

# logstash helm chart

resource "helm_release" "logstash" {
  count      = var.cluster_created ? 1 : 0
  name       = "logstash"
  chart      = "logstash"
  version    = "8.5.1"
  repository = "https://helm.elastic.co"
  namespace  = "elk"

  values = [
    <<EOF
    logstashConfig:
      logstash.yml: |
        http.host: 0.0.0.0
        xpack.monitoring.enabled: false
    logstashPipeline: 
      logstash.conf: |
        input {
          beats {
            port => 5044
          }
        }
        filter {
        }
        output {
          elasticsearch {
            hosts => "https://elasticsearch-master.elk:9200"
            ssl_certificate_verification => false
            user => "elastic"
            password => "${var.elastic_password}"
            manage_template => false
            index => "%%{[@metadata][beat]}-%%{+YYYY.MM.dd}"
            document_type => "%%{[@metadata][type]}"
          }
        }
    service:
      type: ClusterIP
      ports:
        - name: beats
          port: 5044
          protocol: TCP
          targetPort: 5044
        - name: http
          port: 8080
          protocol: TCP
          targetPort: 8080
    resources: 
      requests:
        cpu: "512m"
        memory: "1Gi"
      limits:
        cpu: "1024m"
        memory: "2Gi"
    EOF
  ]

  depends_on = [
    helm_release.elastic
  ]
}


# filebeat helm chart

resource "helm_release" "filebeat" {
  count      = var.cluster_created ? 1 : 0
  name       = "filebeat"
  chart      = "filebeat"
  version    = "8.5.1"
  repository = "https://helm.elastic.co"
  namespace  = "elk"

  values = [
    <<EOF
    filebeatConfig:
        filebeat.yml: |
            filebeat.inputs:
            - type: container
              paths:
                - /var/log/containers/*.log
              processors:
              - add_kubernetes_metadata:
                    host: $${NODE_NAME}
                    matchers:
                    - logs_path:
                        logs_path: "/var/log/containers/"

            output.logstash:
                hosts: ["logstash-logstash.elk:5044"]
    resources: 
      requests:
        cpu: "100m"
        memory: "100Mi"
      limits:
        cpu: "1024m"
        memory: "1000Mi"
    EOF
  ]

  depends_on = [
    helm_release.logstash
  ]

}
