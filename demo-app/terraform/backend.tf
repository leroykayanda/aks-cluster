terraform {
  backend "remote" {
    organization = "RentRahisi"

    workspaces {
      prefix = "azure-demo-app-"
    }
  }

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.104.0"
    }

    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.3"
    }

  }
}
