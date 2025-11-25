resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "name" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_mssql_server" "server" {
  name                         = var.sql_server_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.db_password.result
}


resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAllAzureIPs"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


resource "azurerm_mssql_database" "database" {
  name         = var.database_name
  server_id    = azurerm_mssql_server.server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"
}


resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
}


resource "azurerm_key_vault_secret" "kvsecret" {
  name         = "SqlAdminPassword"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.k8_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "todoaksdns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "standard_d2ds_v5"
  }

  identity {
    type = "SystemAssigned"
  }
}



resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.name.id
}


resource "azurerm_role_assignment" "aks_kv_role" {
  principal_id = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope = azurerm_key_vault.kv.id
}