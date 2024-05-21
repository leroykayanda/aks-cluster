resource "azurerm_resource_group" "rg" {
  name     = "aks-${var.env}"
  location = var.region
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "5.3.0"
  vnet_name           = var.env
  resource_group_name = azurerm_resource_group.rg.name
  address_spaces      = var.address_spaces[var.env]
  subnet_prefixes     = var.subnet_prefixes[var.env]
  subnet_names        = ["private", "public"]
  use_for_each        = true
}

module "aks" {
  source                            = "./modules/aks"
  resource_group_name               = azurerm_resource_group.rg.name
  env                               = var.env
  cluster_name                      = "${var.env}-${var.cluster_name}"
  prefix                            = var.env
  role_based_access_control_enabled = true
  vnet_subnet_id                    = module.network.vnet_subnets[0]
  application_gateway_subnet_id     = module.network.vnet_subnets[1]
  default_node_pool                 = var.default_node_pool[var.env]
  net_profile_service_cidr          = var.net_profile_service_cidr
  net_profile_dns_service_ip        = var.net_profile_dns_service_ip
  automatic_channel_upgrade         = var.automatic_channel_upgrade[var.env]
  log_analytics_workspace_enabled   = var.log_analytics_workspace_enabled
  maintenance_window                = var.maintenance_window
  maintenance_window_auto_upgrade   = var.maintenance_window_auto_upgrade
  maintenance_window_node_os        = var.maintenance_window_node_os
  sku_tier                          = var.sku_tier[var.env]
  rbac_aad                          = var.rbac_aad
  rbac_aad_azure_rbac_enabled       = var.rbac_aad_azure_rbac_enabled
  rbac_aad_managed                  = var.rbac_aad_managed
  admins                            = var.admins
  net_profile_outbound_type         = var.net_profile_outbound_type
  network_plugin                    = var.network_plugin
  location                          = var.region
  gateway_autoscaling               = var.gateway_autoscaling
  cluster_created                   = var.cluster_created[var.env]
  letsencrypt_email                 = var.letsencrypt_email
  letsencrypt_environment           = var.letsencrypt_environment[var.env]
  elastic                           = var.elastic[var.env]
  elastic_password                  = var.elastic_password
  kibana                            = var.kibana[var.env]
  grafana                           = var.grafana[var.env]
  prometheus                        = var.prometheus[var.env]
  slack_incoming_webhook_url        = var.slack_incoming_webhook_url
  grafana_password                  = var.grafana_password
  dns_zone                          = var.dns_zone
  argocd                            = var.argocd[var.env]
  argo_ssh_private_key              = var.argo_ssh_private_key

  providers = {
    kubernetes = kubernetes
    helm       = helm
    grafana    = grafana
  }
}
