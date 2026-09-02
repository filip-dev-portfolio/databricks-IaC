data "azurerm_storage_account" "sta" {
    for_each = local.logic_apps
    name = each.value.storage_account_name
    resource_group_name = each.value.resource_group_name
}

data "azurerm_subnet" "logic_app_subnet" {
    for_each = local.logic_apps
    name = each.value.subnet_name
    virtual_network_name = each.value.virtual_network_name
    resource_group_name = try(each.value.vnet_resource_group_name,each.value.resource_group_name)
}

data "azurerm_user_assigned_identity" "uai" {
    for_each = {
        for k, v in local.logic_apps : k => v if v.user_assigned_identity != null
    }
    name = each.value.user_assigned_identity
    resource_group_name = try(each.value.user_assigned_identity_rg, each.value.resource_group_name)
}

data "azurerm_storage_account" "rbac_sta" {
    for_each = {
        for key, value in local.logic_rbac:
        key => value if value.scope_type == "storage_account"
    }
    name = each.value.storage_account_name
    resource_group_name = each.value.resource_group_name
}