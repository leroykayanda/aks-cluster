data "azurerm_kubernetes_cluster" "cluster" {
  count               = var.cluster_created[var.env] || var.cluster_not_terminated[var.env] ? 1 : 0
  name                = "${var.env}-${var.cluster_name}"
  resource_group_name = azurerm_resource_group.rg.name
}
