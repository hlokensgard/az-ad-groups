variable "azure_ad_group_configuration" {
  type = object({
    administrative_unit_ids    = optional(string, null)
    assignable_to_role         = optional(bool, false)
    auto_subscribe_new_members = optional(bool, false)
    behaviors                  = optional(string, null)
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
    provisioning_options      = optional(string, null)
    security_enabled          = optional(bool, false)
    theme                     = optional(string, null)
    types                     = optional(list(string), null)
    visibility                = optional(string, null)
    writeback_enabled         = optional(string, null)

  })
  description = "description"
}


variable "enable_conditional_access" {
  type        = bool
  description = "This variable is used to enable conditional access for Azure AD group"
  default     = false
}

variable "conditional_access_configuration" {
  type = object({
    display_name = string
    conditions = object({
      application = object({
        exluded_applications  = optional(list(string), null)
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
      custom_controls   = optional(list(string), null)
      operator          = string
      terms_of_use      = optional(list(string), null)
    })
  })
}

