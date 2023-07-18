locals {
  # Getting the ID of the azure ad group that is created 
  azure_ad_group_id = azuread_group.this.id
  # Merging the azure ad group id with the input from the included_groups 
  
  additional_groups = var.conditional_access_configuration != null ? (var.conditional_access_configuration.conditions.users.included_groups != null ? var.conditional_access_configuration.conditions.users.included_groups : [] ) : []
  conditional_access_included_groups = concat([local.azure_ad_group_id], local.additional_groups)

}