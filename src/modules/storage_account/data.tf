data "azurerm_user_assigned_identity" "uai" {
    for_each = {
        for sta_k, sta_v in try(local.storage_accounts, []):
        sta_k => sta_v
        if sta_v.user_assigned_identity != null
    }
    name = each.value.user_assigned_identity
    resource_group_name = each.value.resource_group_name
}

data "azurerm_resource_group" "rg_acc" {
    for_each = {
        for k, v in try(local.access_connector, []):
        k => v if v.access_connector_name != null
    }
    name = each.value.resource_group_name
}

data "azurerm_key_vault" "kv" {
    for_each = {
        for sta_k, sta_v in try(local.storage_accounts, []):
        sta_k => sta_v
        if sta_v.customer_managed_key != null
    }
    name = each.value.customer_managed_key.key_vault_name
    resource_group_name = each.value.resource_group_name
}

data "azurerm_client_config" "current" {}

data "azapi_resource" "access_connector" {
for_each = {
    for k, v in try(local.access_connector, []):
    k => v if v.access_connector_name != null
}
    name = each.value.access_connector_name
    type = "Microsoft.Databricks/accessConnectors"
    parent_id = data.azurerm_resource_group.rg_acc[each.value.storage_account_name].id

}