# grafana namespace

resource "kubernetes_namespace" "grafana" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name = "grafana"
  }
}

# prometheus helm chart

resource "helm_release" "prometheus" {
  count      = var.cluster_created ? 1 : 0
  name       = "prometheus"
  chart      = "prometheus"
  version    = "25.21.0"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = "grafana"

  set {
    name  = "server.persistentVolume.size"
    value = var.prometheus["pv_storage"]
  }

  set {
    name  = "server.retention"
    value = var.prometheus["retention"]
  }

  depends_on = [
    kubernetes_namespace.grafana
  ]

}

# grafana helm chart

resource "helm_release" "grafana" {
  count      = var.cluster_created ? 1 : 0
  name       = "grafana"
  chart      = "grafana"
  version    = "7.3.11"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = "grafana"

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = var.grafana["pv_storage"]
  }

  set {
    name  = "persistence.storageClassName"
    value = var.grafana["storageClassName"]
  }

  set {
    name  = "adminPassword"
    value = var.grafana_password
  }

  values = [
    <<EOF
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server.grafana
        access: proxy
        isDefault: true
dashboardProviders:
    dashboardproviders.yaml:
        apiVersion: 1
        providers:
        - name: 'default'
          orgId: 1
          folder: ''
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards/default
dashboards:
  default:
    kubernetes-dashboard:
      json: |
        ${indent(8, file("${path.module}/dashboard.json"))}
grafana.ini:
  server:
    domain: "${var.grafana["dns_name"]}.${var.grafana["dns_zone"]}"
    root_url: "%(protocol)s://%(domain)s/"
alerting: 
  contactpoints.yaml:
    secret:
      apiVersion: 1
      contactPoints:
        - orgId: 1
          name: slack_alerts
          receivers:
            - uid: slack
              type: slack
              settings:
                url: "${var.slack_incoming_webhook_url}"
  rules.yaml:
    apiVersion: 1
    groups:
      - orgId: 1
        name: evaluation_group
        folder: "${var.env}-env"
        interval: 5m
  policies.yaml:
    policies:
      - orgId: 1
        receiver: slack_alerts
EOF
  ]

}

# grafana dns name

resource "azurerm_dns_a_record" "grafana" {
  count               = var.cluster_created ? 1 : 0
  name                = var.grafana["dns_name"]
  zone_name           = var.grafana["dns_zone"]
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ip.id
}

# grafana tls secret

resource "kubernetes_secret" "grafana" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "grafana-tls-cert"
    namespace = "grafana"
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

# grafana ingress

resource "kubernetes_ingress_v1" "grafana" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "grafana"
    namespace = "grafana"
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
      hosts       = ["${var.grafana["dns_name"]}.${var.grafana["dns_zone"]}"]
      secret_name = "grafana-tls-cert"
    }

    rule {
      host = "${var.grafana["dns_name"]}.${var.grafana["dns_zone"]}"

      http {
        path {
          path = "/"

          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

}
