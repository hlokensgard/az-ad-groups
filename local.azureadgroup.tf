locals {
  azure_ad_group_owners_from_configuration = var.azure_ad_group_configuration.owners == null ? [] : var.azure_ad_group_configuration.owners
  azure_ad_group_owners                    = concat([data.azuread_client_config.current.object_id], local.azure_ad_group_owners_from_configuration)
}