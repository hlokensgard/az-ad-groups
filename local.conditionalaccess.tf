locals {
  # Merging the azure ad group id with the input from the included_groups 
  additional_groups                  = var.conditional_access_configuration != null ? (var.conditional_access_configuration.conditions.users.included_groups != null ? var.conditional_access_configuration.conditions.users.included_groups : []) : []
  conditional_access_included_groups = concat([azuread_group.this.id], local.additional_groups)
}