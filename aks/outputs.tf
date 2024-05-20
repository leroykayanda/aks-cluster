output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "zone_name" {
  value = azurerm_dns_zone.zone.name
}

output "gateway_ip" {
  value = module.aks.gateway_ip
}
