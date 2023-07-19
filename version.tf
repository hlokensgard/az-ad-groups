terraform {
  required_version = "~>1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.65"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.40"
    }
    time_static = {
      source  = "hashicorp/time"
      version = "~>0.9"
    }
  }
}