resource "azurerm_key_vault_key" "this" {
    for_each = local.customer_managed_keys

    name = each.value.name
    key_vault_id = azurerm_key_vault.kv[each.value.kv_name].id
    key_type = each.value.key_type
    key_size = each.value.key_size
    key_opts = each.value.key_opts
}