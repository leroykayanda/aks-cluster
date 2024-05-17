# create dns zone

resource "azurerm_dns_zone" "zone" {
  name                = "azure.rentrahisi.co.ke"
  resource_group_name = azurerm_resource_group.rg.name
}

# resource "azurerm_dns_a_record" "app" {
#   name                = "rr"
#   zone_name           = azurerm_dns_zone.zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 60
#   target_resource_id  = module.aks.gateway_ip
# }
