variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "prefix" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "application_gateway_subnet_id" {
  type = string
}

variable "role_based_access_control_enabled" {
}

variable "default_node_pool" {
  type = any
}

variable "net_profile_service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service"
}

variable "net_profile_dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
}

variable "auto_scaler_profile_expander" {
  type        = string
  description = "How node pools will be expanded to schedule pods incase there are multiple. Possible values are least-waste, priority, most-pods and random. Defaults to random"
  default     = "least-waste"
}

variable "automatic_channel_upgrade" {
  type = string
}

variable "dns_zone" {
  type = string
}

variable "log_analytics_workspace_enabled" {
}

variable "maintenance_window" {
  type = any
}

variable "maintenance_window_auto_upgrade" {
  description = "Maintenance window configuration for auto-upgrade"
  type        = any
}

variable "maintenance_window_node_os" {
  type        = any
  description = "OS security updates"
}

variable "sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
}

variable "rbac_aad" {
  description = "Is Azure Active Directory integration enabled?"
}

variable "rbac_aad_azure_rbac_enabled" {
}

variable "rbac_aad_managed" {
}

variable "env" {
  type        = string
  description = "The environment i.e prod, dev etc"
}

variable "admins" {
  type        = list(string)
  description = "IDs of admin users"
}

variable "net_profile_outbound_type" {
  type = string
}

variable "network_plugin" {
  type = string
}

variable "location" {
  type = string
}

variable "gateway_autoscaling" {
  type = map(number)
}

variable "cluster_created" {
  description = "create applications such as argocd only when the eks cluster has already been created"
}

variable "letsencrypt_email" {
  type        = string
  description = "email to contact you about expiring certificates & issues"
}

variable "elastic" {
  type = any
}

variable "elastic_password" {
  type = string
}

variable "kibana" {
  type = any
}

variable "grafana" {
  type = any
}

variable "prometheus" {
  type = any
}

variable "slack_incoming_webhook_url" {
  type = string
}

variable "letsencrypt_environment" {
  type = string
}

variable "grafana_password" {
  type = string
}

# argocd

variable "argocd" {
  type = any
}

variable "argo_ssh_private_key" {
  description = "The SSH private key"
  type        = string
}

variable "argo_slack_token" {
  type = string
}

variable "argocd_image_updater_values" {
}
