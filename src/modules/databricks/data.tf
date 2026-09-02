data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vnet" {
    for_each = local.databricks_info
    name                = each.value.vnet_name
    resource_group_name = each.value.resource_group_name
}

data "azurerm_subnet" "public" {
    for_each = local.databricks_info
    name                 = each.value.public_subnet_name
    virtual_network_name = each.value.vnet_name
    resource_group_name  = each.value.resource_group_name
}

data "azurerm_subnet" "private" {
    for_each = local.databricks_info
    name                 = each.value.private_subnet_name
    virtual_network_name = each.value.vnet_name
    resource_group_name  = each.value.resource_group_name
}

data "azurerm_key_vault" "this" {
    for_each = {
        for k, v in local.databricks : k => v if v.customer_managed_key != null
    }
    name               = each.value.customer_managed_key.key_vault_name
    resource_group_name = try(each.value.customer_managed_key.resource_group_name, each.value.resource_group_name)
}

data "azurerm_key_vault_key" "this" {
    for_each = {
        for k, v in local.databricks : k => v if v.customer_managed_key != null
    }
    name         = each.value.customer_managed_key.key_name
    key_vault_id = data.azurerm_key_vault.this[each.key].id
}