data "azurerm_client_config" "current" {}

data "azuread_service_principal" "sp" {
  display_name = "bluegreendeployment"
}
