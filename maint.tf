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
resource "azuread_access_package_catalog" "this" {
  count              = var.enable_access_package ? 1 : 0
  description        = var.access_package_configuration.description
  display_name       = var.access_package_configuration.display_name
  externally_visible = var.access_package_configuration.externally_visible
  published          = var.access_package_configuration.published
}

resource "azuread_access_package" "this" {
  count        = var.enable_access_package ? 1 : 0
  catalog_id   = azuread_access_package_catalog.this.id
  display_name = var.access_package_configuration.display_name
  description  = var.access_package_configuration.description
  hidden       = var.access_package_configuration.hidden
}

resource "azuread_access_package_assignment_policy" "this" {
  count             = var.enable_access_package ? 1 : 0
  access_package_id = azuread_access_package.this.id
  description       = var.access_package_configuration.description
  display_name      = var.access_package_configuration.display_name
  duration_in_days  = var.access_package_configuration.duration_in_days
  expiration_date   = var.access_package_configuration.expiration_date
  extension_enabled = var.access_package_configuration.extension_enabled



  dynamic "approval_settings" {
    for_each = var.access_package_configuration.approval_settings != null ? [var.access_package_configuration.approval_settings] : []
    content {
      approval_required_for_extension = approval_settings.value.approval_required_for_extension
      approval_required               = approval_settings.value.approval_required
      dynamic "approval_stage" {
        for_each = approval_settings.value.approval_stage != null ? [approval_settings.value.approval_stage] : []
        content {
          alternative_approval_enabled        = approval_stage.value.alternative_approval_enabled
          approval_timeout_in_days            = approval_stage.value.approval_timeout_in_days
          approver_justification_required     = approval_stage.value.approver_justification_required
          enable_justification_required       = approval_stage.value.enable_justification_required
          enable_alternative_approval_in_days = approval_stage.value.enable_alternative_approval_in_days
          dynamic "primary_approver" {
            for_each = approval_stage.value.primary_approver != null ? [approval_stage.value.primary_approver] : []
            content {
              backup       = primary_approver.value.backup
              object_id    = primary_approver.value.object_id
              subject_type = primary_approver.value.subject_type
            }
          }
          dynamic "alternative_approver" {
            for_each = approval_stage.value.alternative_approver != null ? [approval_stage.value.alternative_approver] : []
            content {
              backup       = alternative_approver.value.backup
              object_id    = alternative_approver.value.object_id
              subject_type = alternative_approver.value.subject_type
            }
          }
        }
      }
      requestor_justification_required = approval_settings.value.requestor_justification_required
    }
  }

  dynamic "assignment_review_settings" {
    for_each = var.access_package_configuration.assignment_review_settings != null ? [var.access_package_configuration.assignment_review_settings] : []
    content {
      access_recommendation_enabled   = assignment_review_settings.value.access_recommendation_enabled
      access_review_timeout_behavior  = assignment_review_settings.value.access_review_timeout_behavior
      approver_justification_required = assignment_review_settings.value.approver_justification_required
      duration_in_days                = assignment_review_settings.value.duration_in_days
      enabled                         = assignment_review_settings.value.enabled
      review_frequency                = assignment_review_settings.value.review_frequency
      review_type                     = assignment_review_settings.value.review_type
      starting_on                     = assignment_review_settings.value.starting_on
      dynamic "reviewer" {
        for_each = assignment_review_settings.value.reviewer != null ? [assignment_review_settings.value.reviewer] : []
        content {
          backup       = reviewer.value.backup
          object_id    = reviewer.value.object_id
          subject_type = reviewer.value.subject_type
        }
      }
    }

  }

  dynamic "question" {
    dynamic "choice" {
      for_each = var.access_package_configuration.question != null ? [var.access_package_configuration.question.choice] : []
      content {
        actual_value = choice.value.actual_value
        dynamic "display_value" {
          for_each = choice.value.display_value != null ? [choice.value.display_value] : []
          content {
            default_text = display_value.value.default_text
            dynamic "localized_text" {
              for_each = display_value.value.localized_text != null ? [display_value.value.localized_text] : []
              content {
                content       = localized_text.value.content
                language_code = localized_text.value.language_code
              }
            }
          }
        }
      }
    }

    dynamic "required" {
      for_each = var.access_package_configuration.question != null ? [var.access_package_configuration.question.required] : []
      content {
        display_name = required.value.display_name
        value        = required.value.value
      }
    }

    dynamic "sequence" {
      for_each = var.access_package_configuration.question != null ? [var.access_package_configuration.question.sequence] : []
      content {
        display_name = sequence.value.display_name
        value        = sequence.value.value
      }
    }

    dynamic "text" {
      for_each = var.access_package_configuration.question != null ? [var.access_package_configuration.question.text] : []
      content {
        default_text = text.value.default_text
        dynamic "localized_text" {
          for_each = text.value.localized_text != null ? [text.value.localized_text] : []
          content {
            content       = localized_text.value.content
            language_code = localized_text.value.language_code
          }
        }
      }
    }

  }

  dynamic "requestor_settings" {
    for_each = var.access_package_configuration.requestor_settings != null ? [var.access_package_configuration.requestor_settings] : []
    content {
      dynamic "requestor" {
        for_each = requestor_settings.value.requestor != null ? [requestor_settings.value.requestor] : []
        content {
          object_id    = requestor.value.object_id
          subject_type = requestor.value.subject_type
        }
      }
      requests_accepted = requestor_settings.value.requests_accepted
      scope_type        = requestor_settings.value.scope_type
    }
  }

}

resource "azuread_access_package_resource_catalog_association" "this" {
  count                  = var.enable_access_package ? 1 : 0
  catalog_id             = azuread_access_package_catalog.this.id
  resource_origin_id     = azuread_group.this.object_id
  resource_origin_system = "AadGroup"
}

resource "azuread_access_package_resource_package_association" "this" {
  access_package_id               = azuread_access_package.this.id
  catalog_resource_association_id = azuread_access_package_resource_catalog_association.this.id
}

resource "azuread_access_package_catalog_role_assignment" "this" {
  role_id             = data.azuread_access_package_catalog_role.example.object_id
  principal_object_id = data.azuread_client_config.current.object_id
  catalog_id          = azuread_access_package_catalog.this.id
}

# Azure Resource Manager (ARM) RBAC access to a given scope 
# Should be based on least priviliged 