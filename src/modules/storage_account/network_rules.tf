resource "azurerm_storage_account_network_rules" "network_rules" {
    for_each = try(local.network_rules, {})
    storage_account_id = azurerm_storage_account.sta[each.value.storage_account_name].id
    default_action = each.value.default_action
    bypass = each.value.bypass
    virtual_network_subnet_ids = lookup(each.value, "virtual_network_subnet_ids", null)
    ip_rules = lookup(each.value, "ip_rules", null)

    dynamic "private_link_access" {
        for_each = lookup(each.value, "private_link_access", [])
        content {
            endpoint_resource_id = (
                try(data.azapi_resource.access_connector[each.value.storage_account_name].id, 
                null) 
            )
            endpoint_tenant_id = try( data.azurerm_client_config.current.tenant_id, null)
        }
    }
    depends_on = [
        azurerm_storage_account.sta,
        azurerm_storage_share.file_share
    ]   
}