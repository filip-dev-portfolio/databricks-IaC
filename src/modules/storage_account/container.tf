resource "azurerm_storage_container" "container" {
    for_each = try(local.sta_containers, {})
    name                  = each.value.name
    storage_account_id = azurerm_storage_account.sta[each.value.storage_account_name].id
    container_access_type = lookup(each.value, "container_access_type", null)
}