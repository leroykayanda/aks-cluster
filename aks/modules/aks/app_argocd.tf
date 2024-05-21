# ns
resource "kubernetes_namespace" "ns" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name = "argocd"
  }
}

#argo helm chart
resource "helm_release" "argocd" {
  count      = var.cluster_created ? 1 : 0
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "6.9.3"

  set {
    name  = "notifications.secret.create"
    value = false
  }

  set {
    name  = "notifications.cm.create"
    value = false
  }

  set {
    name  = "notifications.containerPorts.metrics"
    value = 9002
  }

  values = [
    <<EOT
configs:
  cm:
    "timeout.reconciliation": "60s"
  params:
    "server.insecure": true
EOT
  ]
}

# ingress dns name
resource "azurerm_dns_a_record" "argocd" {
  count               = var.cluster_created ? 1 : 0
  name                = var.argocd["dns_name"]
  zone_name           = var.dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ip.id
}

# ingress tls secret
resource "kubernetes_secret" "argocd" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "tls-cert"
    namespace = "argocd"
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

# ingress

resource "kubernetes_ingress_v1" "argocd" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "argocd"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                                  = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/health-probe-unhealthy-threshold" = "2"
      "appgw.ingress.kubernetes.io/request-timeout"                  = "30"
      "appgw.ingress.kubernetes.io/ssl-redirect"                     = "true"
      "cert-manager.io/cluster-issuer"                               = "letsencrypt-issuer"
      "appgw.ingress.kubernetes.io/backend-protocol"                 = "HTTP"
    }
  }

  spec {
    tls {
      hosts       = ["${var.argocd["dns_name"]}.${var.dns_zone}"]
      secret_name = "tls-cert"
    }

    rule {
      host = "${var.argocd["dns_name"]}.${var.dns_zone}"

      http {
        path {
          path = "/"

          backend {
            service {
              name = "argo-cd-argocd-server"
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

#argo ssh auth

resource "kubernetes_secret" "argo-secret" {
  count = var.cluster_created ? 1 : 0
  metadata {
    name      = "private-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    "type"          = "git"
    "url"           = var.argocd["argo_repo"]
    "sshPrivateKey" = var.argo_ssh_private_key
  }
}
