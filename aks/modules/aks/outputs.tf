output "host" {
  value = module.aks.host
}

output "client_certificate" {
  value = module.aks.client_certificate
}

output "client_key" {
  value = module.aks.client_key
}

output "cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate
}

output "gateway_ip" {
  value = azurerm_public_ip.ip.id
}
