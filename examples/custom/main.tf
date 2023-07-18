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
    enable_conditional_access = true
    conditional_access_configuration = {
        display_name = "testing-module"
        conditions = {
            application = {
                included_applications = ["All"]
            }
            client_app_types = ["browser"]
            users = {
                included_users = ["None"]
            }
        }
        state = "disabled"
        grant_controls = {
            operator = "OR"
            built_in_controls = ["mfa", "compliantDevice"]
        }
    }
}