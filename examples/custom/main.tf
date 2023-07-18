provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

provider "azuread" {
    tenant_id = var.tenant_id
}

# Calling the module 
module "azure_ad_group" {
    source = "../../../az-ad-groups"
    azure_ad_group_configuration = {
        display_name = "testing-module"
        security_enabled = true
    }
}