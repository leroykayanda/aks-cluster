
data "azurerm_client_config" "current" {}

data "terraform_remote_state" "aks" {
  backend = "remote"

  config = {
    organization = "RentRahisi"
    workspaces = {
      name = "aks-${var.env}"
    }
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.env}-${var.cluster_name}"
  resource_group_name = var.resource_group[var.env]
}

data "azurerm_subscription" "current" {}
