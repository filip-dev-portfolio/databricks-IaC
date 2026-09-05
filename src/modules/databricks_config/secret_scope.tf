resource "databricks_secret_scope" "ss" {
    for_each = local.scopes
    name = each.value.name
    keyvault_metadata {
        dns_name = data.azurerm_key_vault.kv[each.key].vault_uri
        resource_id = data.azurerm_key_vault.kv[each.key].id
    }
}