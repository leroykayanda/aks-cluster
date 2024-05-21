output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "gateway_ip" {
  value = azurerm_public_ip.ip.id
}

output "kubelet_identity" {
  value = module.aks.kubelet_identity[0].object_id
}
