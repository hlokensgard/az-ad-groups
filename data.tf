# This is used to get the configuration for the user or service principal that deployes this code 
# This user/SP is set as owner of the Azure AD Group
# Deploying the code with different users or SP will change the owner of the Azure AD Group
data "azuread_client_config" "current" {}

data "azuread_user" "members" {
  for_each            = var.azure_ad_group_configuration.members != null ? toset(var.azure_ad_group_configuration.members) : toset([])
  user_principal_name = each.value
}

data "azurerm_role_definition" "pim_role" {
  count = var.enable_pim ? 1 : 0
  name  = var.pim_configuration.role_definition_display_name
}

data "azuread_access_package_catalog" "this" {
  count        = var.enable_access_package ? (var.access_packages_configuration.create_new_package_catalog == false ? 1 : 0) : 0
  display_name = var.access_packages_configuration.access_package_catalog.display_name
}

data "azuread_access_package" "this" {
  count        = var.enable_access_package ? (var.access_packages_configuration.create_new_access_package == false ? 1 : 0) : 0
  catalog_id   = var.access_packages_configuration.existing_access_package_information.catalog_id
  display_name = var.access_packages_configuration.existing_access_package_information.display_name
}


data "azurerm_subscription" "pim" {
  count           = var.enable_pim ? 1 : 0
  subscription_id = var.pim_configuration.subscription_id
}