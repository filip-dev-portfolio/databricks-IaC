resource "azurerm_storage_account_customer_managed_key" "this" {
    for_each = {
        for sta_k, sta_v in try(local.storage_accounts, []):
        sta_k => sta_v
        if sta_v.customer_managed_key != null
    }
    storage_account_id = azurerm_storage_account.sta[each.key].id
    key_vault_id = data.azurerm_key_vault.kv[each.key].id
    key_name = each.value.customer_managed_key.key_name
    user_assigned_identity_id = try(data.azurerm_user_assigned_identity.uai[each.key].id, null)
}