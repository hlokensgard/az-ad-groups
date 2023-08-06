provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  client_id     = var.client_id
  client_secret = var.client_secret
  tenant_id     = var.tenant_id
}

# Creates an Microsoft Entra ID Group that contains the users that can grant access for the access package for the Azure Landing Zone
module "alz_access_approvers" {
  source = "../../../az-ad-groups"
  azure_ad_group_configuration = {
    display_name          = "Azure-Landing-Zone-Access-Approvers"
    security_enabled      = true
    onpremises_group_type = "UniversalSecurityGroup"
  }
}


# This module call creates an Microsoft Entra ID Group with a new access package and a new access package catalog for the Landing Zone Owners
module "landing_zone_owners" {
  source = "../../../az-ad-groups"
  azure_ad_group_configuration = {
    display_name          = "Landing-Zone-Owners"
    security_enabled      = true
    onpremises_group_type = "UniversalSecurityGroup"
  }

  enable_access_package = true
  access_packages_configuration = {
    create_new_package_catalog = true
    access_package_catalog = {
      display_name = "Landing-Zone"
      description  = "A catalog that contains the different access packages for the Landing Zone"
    }
    create_new_access_package = true
    access_packages = {
      display_name = "Landing-Zone-Owners"
      description  = "A package that gives membership to the Entra ID Group that gives the Owner permission for the Landing Zone management group"
    }
    access_package_assignment_policy = {
      description       = "A policy that ensures that Owner permission for the Landing Zone management group needs to be approved by members of an Entra ID Group"
      display_name      = "Approval Policy"
      duration_in_days  = "90"
      expiration_date   = null # Null since duration in days is set
      extension_enabled = true
      approval_settings = {
        approval_required               = true
        approval_required_for_extension = true
        approval_stage = {
          alternative_approval_enabled        = null
          alternative_approver                = null
          approval_timeout_in_days            = "14" # If a request is not approved within this time period after it is made, it will be automatically rejected.
          approver_justification_required     = true
          enable_alternative_approval_in_days = null
          requestor_justification_required    = null
          primary_approver = {
            backup       = false                                               # If set to true, the approver can be replaced by an alternative approver
            object_id    = module.alz_access_approvers.azuread_group.object_id # The objeect ID for the Entra ID Group that contains members that can grant access for the access package
            subject_type = "groupMembers"                                      # This is set to groupMembers because the object ID is for a group, if it was for a user it would be set to "singleUser"
          }
        }
      }
      assignment_review_settings = null # Not enabled assignment review 
      question = {
        required = true
        text = {
          default_text = "Why do you need Owner permission for the Landing Zone management group?"
        }
      }
      requestor_settings = {
        requests_accepted = true
        scope_type        = "AllExistingDirectoryMemberUsers"
      }
    }
  }
}

# This module call creates an Microsoft Entra ID Group with a new access package and a new access package catalog for the Connectivity Subscription
module "connectivity_owners" {
  source = "../../../az-ad-groups"
  azure_ad_group_configuration = {
    display_name          = "Connectivity-Owners"
    security_enabled      = true
    onpremises_group_type = "UniversalSecurityGroup"
  }

  enable_access_package = true
  access_packages_configuration = {
    create_new_package_catalog = true
    access_package_catalog = {
      display_name = "Platform"
      description  = "A catalog that contains the different access packages for the Platform"
    }
    create_new_access_package = true
    access_packages = {
      display_name = "Connectivity-Owners"
      description  = "A package that gives membership to the Entra ID Group that gives the Owner permission for the Connectivity Subscription"
    }
    access_package_assignment_policy = {
      description       = "A policy that ensures that Owner permission for the connectivity subscripton needs to be approved by members of an Entra ID Group"
      display_name      = "Approval Policy"
      duration_in_days  = "90"
      expiration_date   = null # Null since duration in days is set
      extension_enabled = true
      approval_settings = {
        approval_required               = true
        approval_required_for_extension = true
        approval_stage = {
          alternative_approval_enabled        = null
          alternative_approver                = null
          approval_timeout_in_days            = "14" # If a request is not approved within this time period after it is made, it will be automatically rejected.
          approver_justification_required     = true
          enable_alternative_approval_in_days = null
          requestor_justification_required    = null
          primary_approver = {
            backup       = false                                               # If set to true, the approver can be replaced by an alternative approver
            object_id    = module.alz_access_approvers.azuread_group.object_id # The object ID for the Entra ID Group that contains members that can grant access for the access package
            subject_type = "groupMembers"                                      # This is set to groupMembers because the object ID is for a group, if it was for a user it would be set to "singleUser"
          }
        }
      }
      assignment_review_settings = null # Not enabled assignment review 
      question = {
        required = true
        text = {
          default_text = "Why do you need Owner permission for the Connectivity subscription?"
        }
      }
      requestor_settings = {
        requests_accepted = true
        scope_type        = "AllExistingDirectoryMemberUsers"
      }
    }
  }
  enable_pim = true
  pim_configuration = {
    subscription_id              = var.subscription_id_connectivity
    role_definition_display_name = "Owner"
    schedule = {
      expiration = {
        duration_days = 8
      }
    }
  }
}

# This module call creates an Microsoft Entra ID Group with a new access package for the Connectivity Subscription
module "connectivity_contributors" {
  depends_on = [module.connectivity_owners]
  source     = "../../../az-ad-groups"
  azure_ad_group_configuration = {
    display_name          = "Connectivity-Contributors"
    security_enabled      = true
    onpremises_group_type = "UniversalSecurityGroup"
  }

  enable_access_package = true
  access_packages_configuration = {
    create_new_package_catalog = false
    access_package_catalog = {
      display_name = "Platform"
    }
    create_new_access_package = true
    access_packages = {
      display_name = "Connectivity-Contributors"
      description  = "A package that gives membership to the Entra ID Group that gives the Contributor permission for the Connectivity Subscription"
    }
    access_package_assignment_policy = {
      description       = "A policy that ensures that Contributor permission for the connectivity subscripton needs to be approved by members of an Entra ID Group"
      display_name      = "Approval Policy"
      duration_in_days  = "90"
      expiration_date   = null # Null since duration in days is set
      extension_enabled = true
      approval_settings = {
        approval_required               = true
        approval_required_for_extension = true
        approval_stage = {
          alternative_approval_enabled        = null
          alternative_approver                = null
          approval_timeout_in_days            = "14" # If a request is not approved within this time period after it is made, it will be automatically rejected.
          approver_justification_required     = true
          enable_alternative_approval_in_days = null
          requestor_justification_required    = null
          primary_approver = {
            backup       = false                                               # If set to true, the approver can be replaced by an alternative approver
            object_id    = module.alz_access_approvers.azuread_group.object_id # The object ID for the Entra ID Group that contains members that can grant access for the access package
            subject_type = "groupMembers"                                      # This is set to groupMembers because the object ID is for a group, if it was for a user it would be set to "singleUser"
          }
        }
      }
      assignment_review_settings = null # Not enabled assignment review 
      question = {
        required = true
        text = {
          default_text = "Why do you need Contributor permission for the Connectivity subscription?"
        }
      }
      requestor_settings = {
        requests_accepted = true
        scope_type        = "AllExistingDirectoryMemberUsers"
      }
    }
  }
  enable_pim = true
  pim_configuration = {
    subscription_id              = var.subscription_id_connectivity
    role_definition_display_name = "Contributor"
    schedule = {
      expiration = {
        duration_days = 8
      }
    }
  }
}