# create dns zone

resource "azurerm_dns_zone" "zone" {
  name                = "azure.rentrahisi.co.ke"
  resource_group_name = azurerm_resource_group.rg.name
}
