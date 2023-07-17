# Resource documentation: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
# Microsoft recommendation: 
# Azure AD Group
resource "azuread_group" "this" {
  administrative_unit_ids    = var.azure_ad_group_configuration.administrative_unit_ids
  assignable_to_role         = var.azure_ad_group_configuration.assignable_to_role
  auto_subscribe_new_members = var.azure_ad_group_configuration.auto_subscribe_new_members
  behaviors                  = var.azure_ad_group_configuration.behaviors
  description                = var.azure_ad_group_configuration.description
  display_name               = var.azure_ad_group_configuration.display_name
  external_senders_allowed   = var.azure_ad_group_configuration.external_senders_allowed
  hide_from_address_lists    = var.azure_ad_group_configuration.hide_from_address_lists
  hide_from_outlook_clients  = var.azure_ad_group_configuration.hide_from_outlook_clients
  mail_enabled               = var.azure_ad_group_configuration.mail_enabled
  mail_nickname              = var.azure_ad_group_configuration.mail_nickname
  onpremises_group_type      = var.azure_ad_group_configuration.onpremises_group_type
  prevent_duplicate_names    = var.azure_ad_group_configuration.prevent_duplicate_names
  provisioning_options       = var.azure_ad_group_configuration.provisioning_options
  security_enabled           = var.azure_ad_group_configuration.security_enabled
  theme                      = var.azure_ad_group_configuration.theme
  types                      = var.azure_ad_group_configuration.types
  visibility                 = var.azure_ad_group_configuration.visibility
  writeback_enabled          = var.azure_ad_group_configuration.writeback_enabled

  owners = local.azure_ad_group_owners

  dynamic "dynamic_membership" {
    for_each = var.azure_ad_group_configuration.dynamic_membership != null ? var.azure_ad_group_configuration.dynamic_membership : []
    content {
      enabled = dynamic_membership.value.enabled
      rule    = dynamic_membership.value.rule
    }
  }
}


# Azure AD Group members 
resource "azuread_group_member" "this" {
  for_each         = var.azure_ad_group_configuration.members != null ? data.azuread_group_member.members : []
  group_object_id  = azuread_group.this.id
  member_object_id = each.value.id
}

# Conditional access policy 
# Resource documentation: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/conditional_access_policy
# Microsoft recommendatation 
resource "azuread_conditional_access_policy" "this" {

  count        = var.enable_conditional_access ? 1 : 0
  display_name = var.conditional_access_configuration.display_name
  state        = var.conditional_access_configuration.state

  condition {
    client_app_types    = var.conditional_access_configuration.conditions.client_app_types
    sign_in_risk_levels = var.conditional_access_configuration.conditions.sign_in_risk_levels
    user_risk_levels    = var.conditional_access_configuration.conditions.user_risk_levels
    # Need to make every block optional/dynamic based on the input variables
    application {
      excluded_applications = var.conditional_access_configuration.conditions.application.excluded_applications
      included_applications = var.conditional_access_configuration.conditions.application.included_applications
      included_user_actions = var.conditional_access_configuration.conditions.application.included_user_actions
    }
    users {
      excluded_groups = var.conditional_access_configuration.conditions.users.excluded_groups
      excluded_roles  = var.conditional_access_configuration.conditions.users.excluded_roles
      excluded_users  = var.conditional_access_configuration.conditions.users.excluded_users
      included_groups = local.conditional_access_included_groups
      included_roles  = var.conditional_access_configuration.conditions.users.included_roles
      included_users  = var.conditional_access_configuration.conditions.users.included_users
    }

    dynamic "client_application" {
      for_each = var.conditional_access_configuration.conditions.client_applications.client_application != null ? [var.conditional_access_configuration.conditions.client_applications.client_application] : []
      content {
        excluded_service_principals = var.conditional_access_configuration.conditions.client_applications.excluded_service_principals
        included_service_principals = var.conditional_access_configuration.conditions.client_applications.included_service_principals
      }
    }

    dynamic "devices" {
      for_each = var.conditional_access_configuration.conditions.devices.devices != null ? [var.conditional_access_configuration.conditions.devices.devices] : []
      content {
        filter {
          mode = var.conditional_access_configuration.conditions.devices.filter.mode
          rule = var.conditional_access_configuration.conditions.devices.filter.rule
        }
      }
    }

    dynamic "location" {
      for_each = var.conditional_access_configuration.conditions.location.location != null ? [var.conditional_access_configuration.conditions.location.location] : []
      content {
        exclude_locations = var.conditional_access_configuration.conditions.location.exclude_locations
        include_locations = var.conditional_access_configuration.conditions.location.include_locations
      }
    }

    dynamic "platforms" {
      for_each = var.conditional_access_configuration.conditions.platforms.platforms != null ? [var.conditional_access_configuration.conditions.platforms.platforms] : []
      content {
        exclude_platforms = var.conditional_access_configuration.conditions.platforms.exclude_platforms
        include_platforms = var.conditional_access_configuration.conditions.platforms.include_platforms
      }
    }
  }

  dynamic "session_controls" {
    for_each = var.conditional_access_configuration.session_controls != null ? [var.conditional_access_configuration.session_controls] : []
    content {
      application_enforced_restrictions_enabled = session_controls.value.application_enforced_restrictions_enabled
      cloud_app_security_enabled                = session_controls.value.cloud_app_security_enabled
      disable_resilience_defaults               = session_controls.value.disable_resilience_defaults
      persistent_browser_enabled                = session_controls.value.persistent_browser_enabled
      sign_in_frequency                         = session_controls.value.sign_in_frequency
      sign_in_frequency_period                  = session_controls.value.sign_in_frequency_period
    }
  }

  grant_controls {
    built_in_controls = var.conditional_access_configuration.grant_controls.built_in_controls
    custom_controls   = var.conditional_access_configuration.grant_controls.custom_controls
    operator          = var.conditional_access_configuration.grant_controls.operator
    terms_of_use      = var.conditional_access_configuration.grant_controls.terms_of_use
  }
}



# Access packages 



# Azure Resource Manager (ARM) RBAC access to a given scope 
# Should be based on least priviliged 