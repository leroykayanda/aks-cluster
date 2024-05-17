provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "grafana" {
  url                  = "https://${var.grafana[var.env]["dns_name"]}.${var.grafana[var.env]["dns_zone"]}"
  auth                 = "${var.grafana_user}:${var.grafana_password}"
  insecure_skip_verify = true
}

provider "kubernetes" {
  host                   = var.cluster_created[var.env] ? data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.host : ""
  client_certificate     = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.client_certificate) : ""
  client_key             = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.client_key) : ""
  cluster_ca_certificate = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.cluster_ca_certificate) : ""
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_created[var.env] ? data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.host : ""
    client_certificate     = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.client_certificate) : ""
    client_key             = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.client_key) : ""
    cluster_ca_certificate = var.cluster_created[var.env] ? base64decode(data.azurerm_kubernetes_cluster.cluster[0].kube_admin_config.0.cluster_ca_certificate) : ""
  }
}
