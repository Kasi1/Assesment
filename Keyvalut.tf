data "azurerm_key_vault_secret" "Secret" {
name = "Dev"
vault_uri = "enter valut URI"
}



admin_password = "${data.azurerm_key_vault_secret.Secret.value}"
