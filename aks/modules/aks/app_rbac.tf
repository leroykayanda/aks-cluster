# create admin group

resource "azuread_group" "admins" {
  display_name       = "aks-admins-${var.env}"
  security_enabled   = true
  members            = var.admins
  assignable_to_role = true
}

# allow admins to run az aks get-credentials

resource "azurerm_role_assignment" "list_credentials" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_group.admins.object_id
}

# give admins access to key vault

resource "azurerm_role_assignment" "key_vault" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.admins.object_id
}

# add super-user access to admin group

# resource "azurerm_role_assignment" "aks_cluster_admin_assignment" {
#   scope                = "${data.azurerm_subscription.sub.id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.cluster_name}"
#   role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
#   principal_id         = azuread_group.admins.object_id
# }

