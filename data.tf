# This is used to get the configuration for the user or service principal that deployes this code 
# This user/SP is set as owner of the Azure AD Group
# Deploying the code with different users or SP will change the owner of the Azure AD Group
data "azuread_client_config" "current" {}

data "azuread_user" "members" {
  for_each            = var.azure_ad_group_configuration.members
  user_principal_name = each.value
}

data "azuread_access_package_catalog_role" "example" {
  display_name = "Catalog owner"
}