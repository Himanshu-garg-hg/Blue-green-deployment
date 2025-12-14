ephemeral "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "new_k8s" {
  source              = "../child_module_k8"
  resource_group_name = var.resource_group_name
  location            = var.location
  acr_name            = var.acr_name
  sql_server_name     = var.sql_server_name
  database_name       = var.database_name
  k8_name             = var.k8_name
  key_vault_name      = var.key_vault_name
  kv_secret_name      = var.kv_secret_name
  db_password         = ephemeral.random_password.db_password.result
}
