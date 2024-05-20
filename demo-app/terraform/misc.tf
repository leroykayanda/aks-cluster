# key vault
resource "azurerm_key_vault" "kv" {
  name                          = "${var.env}-${var.service}"
  location                      = var.region
  resource_group_name           = var.resource_group[var.env]
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = true
}

# app namespace
resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.service
  }
}

# workload identity

# https://surajblog.medium.com/workload-identity-in-aks-with-terraform-9d6866b2bfa2

# create managed identity that will be assumed by pods
resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "workload_identity"
  resource_group_name = var.resource_group[var.env]
  location            = var.region
}

// Allow our identity to be assumed by a Pod in the cluster
resource "azurerm_federated_identity_credential" "federated_identity" {
  name                = "federated_identity"
  resource_group_name = var.resource_group[var.env]
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.terraform_remote_state.aks.outputs.oidc_issuer_url
  subject             = "system:serviceaccount:${var.service}:${var.service}"
}

// Give our managed identity some permissions
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "app_permissions" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}

# service account
resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.service
    namespace = var.service
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.workload_identity.client_id
      "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
    }
  }
}

# app DNS record
resource "azurerm_dns_a_record" "app" {
  name                = var.service
  zone_name           = data.terraform_remote_state.aks.outputs.zone_name
  resource_group_name = var.resource_group[var.env]
  ttl                 = 300
  target_resource_id  = data.terraform_remote_state.aks.outputs.gateway_ip
}

# ACR registry
resource "azurerm_container_registry" "acr" {
  name                = replace("${var.env}-${var.service}", "-", "")
  resource_group_name = var.resource_group[var.env]
  location            = var.region
  sku                 = var.acr_sku[var.env]
  admin_enabled       = var.acr_admin_enabled
}