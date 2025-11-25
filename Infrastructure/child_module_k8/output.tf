output "db_password_secret_uri" {
  value = azurerm_key_vault_secret.kvsecret.id
}
