variable "azure_ad_group_configuration" {
  description = "This variable is used to configure Azure AD group"
  type = object({
    administrative_unit_ids    = optional(set(string), null)
    assignable_to_role         = optional(bool, false)
    auto_subscribe_new_members = optional(bool, false)
    behaviors                  = optional(set(string), null)
    description                = optional(string, null)
    display_name               = string
    dynamic_membership = optional(object({
      enabled = bool
      rule    = string
    }), null)
    external_senders_allowed  = optional(bool, null)
    hide_from_address_lists   = optional(bool, null)
    hide_from_outlook_clients = optional(bool, null)
    mail_enabled              = optional(bool, null)
    mail_nickname             = optional(bool, null)
    members                   = optional(list(string), null)
    onpremises_group_type     = optional(string, "UniversalSecurityGroup")
    owners                    = optional(list(string), null)
    prevent_duplicate_names   = optional(bool, true)
    provisioning_options      = optional(set(string), null)
    security_enabled          = optional(bool, true)
    theme                     = optional(string, null)
    types                     = optional(list(string), null)
    visibility                = optional(string, null)
    writeback_enabled         = optional(string, false)
  })
}


variable "enable_conditional_access" {
  description = "This variable is used to enable conditional access for Azure AD group"
  type        = bool
  default     = false
}

variable "conditional_access_configuration" {
  description = "This variable is used to configure conditional access for Azure AD group"
  type = object({
    display_name = string
    conditions = object({
      application = object({
        excluded_applications  = optional(list(string), null)
        included_applications = optional(list(string), null)
        included_user_actions = optional(list(string), null)
      })
      client_app_types = list(string)
      users = object({
        excluded_groups = optional(list(string), null)
        excluded_roles  = optional(list(string), null)
        excluded_users  = optional(list(string), null)
        included_groups = optional(list(string), null)
        included_roles  = optional(list(string), null)
        included_users  = optional(list(string), null)
      })
      client_applications = optional(object({
        excluded_service_principals = optional(list(string), null)
        included_service_principals = optional(list(string), null)
      }), null)
      devices = optional(object({
        filter = optional(object({
          mode = string
          rule = string
        }), null)
      }), null)
      locations = optional(object({
        excluded_locations = optional(list(string), null)
        included_locations = list(string)
      }), null)
      platforms = optional(object({
        excluded_platforms = optional(list(string), null)
        included_platforms = optional(list(string), null)
      }), null)
      sign_in_risk_levels = optional(list(string), null)
      user_risk_levels    = optional(list(string), null)
    })
    session_controls = optional(object({
      application_enforced_restrictions_enabled = optional(bool, null)
      cloud_app_security_enabled                = optional(bool, null)
      disable_resilience_defaults               = optional(bool, null)
      persistent_browser_mode                   = optional(string, null)
      sign_in_frequency                         = optional(string, null)
      sign_in_frequency_period                  = optional(string, null)
    }), null)
    state = string
    grant_controls = object({
      built_in_controls = list(string)
      custom_authentication_factors   = optional(list(string), null)
      operator          = string
      terms_of_use      = optional(list(string), null)
    })
  })
  default = null
}

variable "enable_access_package" {
  description = "This variable is used to enable access packages for Azure AD group"
  type        = bool
  default     = false
}

variable "access_packages_configuration" {
  description = "This variable is used to configure access packages for Azure AD group"
  type = object({
    create_new_package_catalog = optional(bool, false)
    access_package_catalog = optional(object({
      display_name       = string
      description        = string
      externally_visible = optional(bool, null)
      published          = optional(bool, null)
    }), null)
    access_packages = object({
      display_name = string
      description  = string
      hidden       = optional(bool, null)
      catalog_display_name = optional(string, null)
    })
    access_package_assignment_policy = object({
      approval_settings = optional(object({
        approval_required_for_extension = optional(bool, null)
        approval_required               = optional(bool, null)
        approval_stage = optional(object({
          alternative_approval_enabled = optional(bool, null)
          alternative_approver = optional(object({
            backup       = optional(bool, null)
            object_id    = optional(string, null)
            subject_type = string
          }), null)
          approval_timeout_in_days            = optional(string, null)
          approver_justification_required     = optional(bool, null)
          enable_alternative_approval_in_days = optional(string, null)
          primary_approver = optional(object({
            backup       = optional(bool, null)
            object_id    = optional(string, null)
            subject_type = string
          }), null)
        }), null)
        requestor_justification_required = optional(bool, null)
      }), null)
      assignment_review_settings = optional(object({
        access_recommendation_enabled   = optional(bool, null)
        access_review_timeout_behavior  = optional(string, null)
        approver_justification_required = optional(bool, null)
        duration_in_days                = number
        enabled                         = optional(bool, null)
        review_frequency                = optional(string, null)
        review_type                     = optional(string, null)
        reviewer = optional(object({
          backup       = optional(bool, null)
          object_id    = optional(string, null)
          subject_type = string
        }), null)
        starting_on = optional(string, null)
      }), null)
      description       = string
      display_name      = string
      duration_in_days  = optional(string, null)
      expiration_date   = optional(string, null)
      extension_enabled = optional(bool, null)
      question = optional(object({
        choice = optional(object({
          actual_value = string
          display_value = object({
            default_text = string
            localized_texts = optional(object({
              content       = string
              language_code = string
            }), null)
          })
        }), null)
        required = optional(bool, null)
        sequence = optional(string, null)
        text = object({
          default_text = string
          localized_texts = optional(object({
            content       = string
            language_code = string
          }), null)
        })
      }), null)
      requestor_settings = optional(object({
        requestor = optional(object({
          object_id    = optional(string, null)
          subject_type = string
        }), null)
        requestor_accepted = optional(bool, null)
        scope_type         = optional(string, null)
      }), null)
    })
  })
  default = null
}

variable "enable_pim" {
  description = "This variable is used to enable pim for Azure AD group"
  type        = bool
  default     = false
}

variable "pim_configuration" {
  description = "This variable is used to configure pim for Azure AD group"
  type = object({
    scope              = string
    principal_id       = string
    principal_type     = string
    role_definition_id = string
    schedule = optional(object({
      expiration = optional(object({
        duration_days  = optional(string, null)
        duration_hours = optional(string, null)
        end_date_time  = optional(string, null)
      }), null)
      start_date_time = optional(string, null)
    }), null)
  })
  default = null
}
