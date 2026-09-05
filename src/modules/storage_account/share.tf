resource "azurerm_storage_share" "file_share" {
    for_each = try(local.file_shares, {})
    name                  = each.value.name
    storage_account_id = azurerm_storage_account.sta[each.value.storage_account_name].id
    quota                 = each.value.quota
    depends_on = [
        azurerm_storage_account.sta
    ]
}