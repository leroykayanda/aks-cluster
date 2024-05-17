resource "azurerm_public_ip" "ip" {
  name                = "${var.env}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  zones               = [1, 2, 3]
  sku                 = "Standard"
}

locals {
  http_listener_name             = "listener"
  backend_address_pool_name      = "backend-pool"
  backend_http_settings_name     = "backend-settings"
  frontend_ip_configuration_name = "frontend-ip"
  frontend_port_name             = "frontend-port"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "${var.env}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = [1, 2, 3]
  enable_http2        = true

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = var.gateway_autoscaling["min_capacity"]
    max_capacity = var.gateway_autoscaling["max_capacity"]
  }

  gateway_ip_configuration {
    name      = "gateway-ip"
    subnet_id = var.application_gateway_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  lifecycle {
    ignore_changes = [request_routing_rule, probe, http_listener, backend_http_settings, backend_address_pool, tags, frontend_port, redirect_configuration, ssl_certificate]
  }
}
