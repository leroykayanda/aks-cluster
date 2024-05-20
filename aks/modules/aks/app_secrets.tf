# https://external-secrets.io/latest/provider/azure-key-vault/#referenced-service-account
resource "helm_release" "secrets" {
  count      = var.cluster_created ? 1 : 0
  version    = "0.9.18"
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
}

resource "helm_release" "reloader" {
  count      = var.cluster_created ? 1 : 0
  version    = "1.0.97"
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  namespace  = "kube-system"

  set {
    name  = "reloader.reloadStrategy"
    value = "annotations"
  }
}
