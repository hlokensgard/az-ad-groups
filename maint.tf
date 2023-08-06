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
    for_each = var.azure_ad_group_configuration.dynamic_membership != null ? [var.azure_ad_group_configuration.dynamic_membership] : []
    content {
      enabled = dynamic_membership.value.enabled
      rule    = dynamic_membership.value.rule
    }
  }
}


# Azure AD Group members 
resource "azuread_group_member" "this" {
  for_each         = var.azure_ad_group_configuration.members != null ? toset([for user in data.azuread_user.members : user.object_id]) : toset([])
  group_object_id  = azuread_group.this.id
  member_object_id = each.value
}

# Conditional access policy 
# Resource documentation: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/conditional_access_policy
# Microsoft recommendatation
resource "azuread_conditional_access_policy" "this" {
  depends_on   = [azuread_group.this]
  count        = var.enable_conditional_access ? 1 : 0
  display_name = var.conditional_access_configuration.display_name
  state        = var.conditional_access_configuration.state

  dynamic "conditions" {
    for_each = var.conditional_access_configuration.conditions != null ? [var.conditional_access_configuration.conditions] : []
    content {
      client_app_types    = conditions.value.client_app_types
      sign_in_risk_levels = conditions.value.sign_in_risk_levels
      user_risk_levels    = conditions.value.user_risk_levels
      dynamic "applications" {
        for_each = conditions.value.application != null ? [conditions.value.application] : []
        content {
          excluded_applications = applications.value.excluded_applications
          included_applications = applications.value.included_applications
          included_user_actions = applications.value.included_user_actions
        }
      }
      dynamic "users" {
        for_each = conditions.value.users != null ? [conditions.value.users] : []
        content {
          excluded_groups = users.value.excluded_groups
          excluded_roles  = users.value.excluded_roles
          excluded_users  = users.value.excluded_users
          included_groups = local.conditional_access_included_groups
          included_roles  = users.value.included_roles
          included_users  = users.value.included_users
        }
      }

      dynamic "client_applications" {
        for_each = var.conditional_access_configuration.conditions.client_applications != null ? [var.conditional_access_configuration.conditions.client_applications] : []
        content {
          excluded_service_principals = client_applications.value.excluded_service_principals
          included_service_principals = client_applications.value.included_service_principals
        }
      }

      dynamic "devices" {
        for_each = var.conditional_access_configuration.conditions.devices != null ? [var.conditional_access_configuration.conditions.devices] : []
        content {
          filter {
            mode = var.conditional_access_configuration.conditions.devices.filter.mode
            rule = var.conditional_access_configuration.conditions.devices.filter.rule
          }
        }
      }

      dynamic "locations" {
        for_each = var.conditional_access_configuration.conditions.locations != null ? [var.conditional_access_configuration.conditions.locations] : []
        content {
          excluded_locations = locations.value.excluded_locations
          included_locations = locations.value.included_locations
        }
      }

      dynamic "platforms" {
        for_each = var.conditional_access_configuration.conditions.platforms != null ? [var.conditional_access_configuration.conditions.platforms] : []
        content {
          excluded_platforms = platforms.value.excluded_platforms
          included_platforms = platforms.value.included_platforms
        }
      }
    }
  }

  dynamic "session_controls" {
    for_each = var.conditional_access_configuration.session_controls != null ? [var.conditional_access_configuration.session_controls] : []
    content {
      application_enforced_restrictions_enabled = session_controls.value.application_enforced_restrictions_enabled
      cloud_app_security_policy                 = session_controls.value.cloud_app_security_policy
      disable_resilience_defaults               = session_controls.value.disable_resilience_defaults
      persistent_browser_mode                   = session_controls.value.persistent_browser_mode
      sign_in_frequency                         = session_controls.value.sign_in_frequency
      sign_in_frequency_period                  = session_controls.value.sign_in_frequency_period
    }
  }

  dynamic "grant_controls" {
    for_each = var.conditional_access_configuration.grant_controls != null ? [var.conditional_access_configuration.grant_controls] : []
    content {
      built_in_controls             = grant_controls.value.built_in_controls
      custom_authentication_factors = grant_controls.value.custom_authentication_factors
      operator                      = grant_controls.value.operator
      terms_of_use                  = grant_controls.value.terms_of_use
    }
  }
}


# Access packages 
resource "azuread_access_package_catalog" "this" {
  depends_on         = [azuread_group.this]
  count              = var.enable_access_package ? (var.access_packages_configuration.create_new_package_catalog ? 1 : 0) : 0
  description        = var.access_packages_configuration.access_package_catalog.description
  display_name       = var.access_packages_configuration.access_package_catalog.display_name
  externally_visible = var.access_packages_configuration.access_package_catalog.externally_visible
  published          = var.access_packages_configuration.access_package_catalog.published
}

resource "azuread_access_package" "this" {
  depends_on = [azuread_group.this]
  # The count is design to allow for null value in the var.access_packages_configuration.create_new_access_package 
  count        = var.enable_access_package ? (var.access_packages_configuration.create_new_access_package ? 1 : 0) : 0
  catalog_id   = var.access_packages_configuration.create_new_package_catalog ? azuread_access_package_catalog.this[0].id : data.azuread_access_package_catalog.this[0].id
  display_name = var.access_packages_configuration.access_packages.display_name
  description  = var.access_packages_configuration.access_packages.description
  hidden       = var.access_packages_configuration.access_packages.hidden
}

resource "azuread_access_package_assignment_policy" "this" {
  depends_on        = [azuread_group.this]
  count             = var.enable_access_package ? (var.access_packages_configuration.create_new_access_package ? 1 : 0) : 0
  access_package_id = var.access_packages_configuration.create_new_access_package ? azuread_access_package.this[0].id : data.azuread_access_package.this[0].id
  description       = var.access_packages_configuration.access_package_assignment_policy.description
  display_name      = var.access_packages_configuration.access_package_assignment_policy.display_name
  duration_in_days  = var.access_packages_configuration.access_package_assignment_policy.duration_in_days
  expiration_date   = var.access_packages_configuration.access_package_assignment_policy.expiration_date
  extension_enabled = var.access_packages_configuration.access_package_assignment_policy.extension_enabled



  dynamic "approval_settings" {
    for_each = var.access_packages_configuration.access_package_assignment_policy.approval_settings != null ? [var.access_packages_configuration.access_package_assignment_policy.approval_settings] : []
    content {
      approval_required_for_extension = approval_settings.value.approval_required_for_extension
      approval_required               = approval_settings.value.approval_required
      dynamic "approval_stage" {
        for_each = approval_settings.value.approval_stage != null ? [approval_settings.value.approval_stage] : []
        content {
          alternative_approval_enabled        = approval_stage.value.alternative_approval_enabled
          approval_timeout_in_days            = approval_stage.value.approval_timeout_in_days
          approver_justification_required     = approval_stage.value.approver_justification_required
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
    for_each = var.access_packages_configuration.access_package_assignment_policy.assignment_review_settings != null ? [var.access_packages_configuration.access_package_assignment_policy.assignment_review_settings] : []
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
    for_each = var.access_packages_configuration.access_package_assignment_policy.question != null ? [var.access_packages_configuration.access_package_assignment_policy.question] : []
    content {
      dynamic "choice" {
        for_each = var.access_packages_configuration.access_package_assignment_policy.question.choice != null ? [var.access_packages_configuration.access_package_assignment_policy.question.choice] : []
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
      required = question.value.required
      sequence = question.value.sequence
      dynamic "text" {
        for_each = var.access_packages_configuration.access_package_assignment_policy.question != null ? [var.access_packages_configuration.access_package_assignment_policy.question.text] : []
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
  }

  dynamic "requestor_settings" {
    for_each = var.access_packages_configuration.access_package_assignment_policy.requestor_settings != null ? [var.access_packages_configuration.access_package_assignment_policy.requestor_settings] : []
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
  depends_on             = [azuread_group.this]
  count                  = var.enable_access_package ? (var.access_packages_configuration.create_new_access_package ? 1 : 0) : 0
  catalog_id             = var.access_packages_configuration.create_new_package_catalog ? azuread_access_package_catalog.this[0].id : data.azuread_access_package_catalog.this[0].id
  resource_origin_id     = azuread_group.this.object_id
  resource_origin_system = "AadGroup"
}

resource "azuread_access_package_resource_package_association" "this" {
  depends_on                      = [azuread_group.this]
  count                           = var.enable_access_package ? (var.access_packages_configuration.create_new_access_package ? 1 : 0) : 0
  access_package_id               = azuread_access_package.this[0].id
  catalog_resource_association_id = azuread_access_package_resource_catalog_association.this[0].id
}


# Azure Resource Manager (ARM) RBAC PIM Role Assignment
resource "azurerm_pim_eligible_role_assignment" "this" {
  depends_on         = [azuread_group.this]
  count              = var.enable_pim ? 1 : 0
  principal_id       = azuread_group.this.object_id
  role_definition_id = "${data.azurerm_subscription.pim[0].id}${data.azurerm_role_definition.pim_role[0].id}"
  scope              = data.azurerm_subscription.pim[0].id

  dynamic "schedule" {
    for_each = var.pim_configuration.schedule != null ? [var.pim_configuration.schedule] : []
    content {
      dynamic "expiration" {
        for_each = schedule.value.expiration != null ? [schedule.value.expiration] : []
        content {
          duration_days  = expiration.value.duration_days
          duration_hours = expiration.value.duration_hours
          end_date_time  = expiration.value.end_date_time
        }
      }
      start_date_time = time_static.pim_start_time[0].rfc3339
    }
  }
  justification = "Expiration Duration Set"

  ticket {
    number = "1"
    system = "Example ticket system"
  }
}

resource "time_static" "pim_start_time" {
  count = var.enable_pim ? 1 : 0
}
