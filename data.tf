# This is used to get the configuration for the user or service principal that deployes this code 
# This user/SP is set as owner of the Azure AD Group
# Deploying the code with different users or SP will change the owner of the Azure AD Group
data "azuread_client_config" "current" {}

data "azuread_user" "members" {
  for_each            = var.azure_ad_group_configuration.members != null ? toset(var.azure_ad_group_configuration.members) : toset([])
  user_principal_name = each.value
}

/* data "azuread_access_package_catalog_role" "this" {
  count = var.enable_pim ? 1 : 0
  display_name = "Catalog Owner"
} */

data "azurerm_role_definition" "pim_role" {
  count = var.enable_pim ? 1 : 0
  name = "Reader"
}

data "azuread_access_package_catalog" "this" {
  count = var.enable_access_package ? (var.access_packages_configuration.create_new_package_catalog ? 1 : 0) : 0
  display_name = var.access_packages_configuration.access_packages.catalog_display_name
}