provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  client_id     = var.client_id
  client_secret = var.client_secret
  tenant_id     = var.tenant_id
}

# Calling the module 
module "azure_ad_group" {
  source = "../../../az-ad-groups"
  azure_ad_group_configuration = {
    display_name     = "testing-az-ad-groups-module"
    security_enabled = true
    members          = ["testuser@somedomain.com"]
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
      operator          = "OR"
      built_in_controls = ["mfa", "compliantDevice"]
    }
  }

  enable_access_package = true
  access_packages_configuration = {
    create_new_package_catalog = true
    access_package_catalog = {
      display_name = "testing-catalog"
      description  = "A testing catalog"
    }
    access_packages = {
      display_name = "Testing package"
      description  = "A testing package"
    }
    access_package_assignment_policy = {
      description  = "A testing policy"
      display_name = "Testing policy"
      approval_settings = {
        approval_required               = true
        approval_required_for_extension = true
        approval_stage = {
          approval_timeout_in_days = "14"
          primary_approver = {
            backup       = true
            object_id    = "ObjectId of the user"
            subject_type = "singleUser"
          }
        }
      }
      assignment_review_settings = {
        enabled                        = true
        review_frequency               = "weekly"
        duration_in_days               = 3
        review_type                    = "Self"
        access_review_timeout_behavior = "keepAccess"
      }
      duration_in_days = "90"
      question = {
        choice = {
          actual_value = "Yes"
          display_value = {
            default_text = "Yes"
          }
        }
        text = {
          default_text = "Do you want to request access?"
        }
      }
    }
  }
  enable_pim = true
  pim_configuration = {
    subscription_id              = var.subscription_id
    role_definition_display_name = "Owner"
    schedule = {
      expiration = {
        duration_days = 8
      }
    }
  }
}