resource "azurerm_databricks_workspace" "databricks" {
    for_each = local.databricks

    infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
    location                          = each.value.location
    managed_resource_group_name       = each.value.managed_resource_group_name
    name                              = each.value.databrick_name
    network_security_group_rules_required = each.value.network_security_group_rules_required
    public_network_access_enabled     = each.value.public_network_access_enabled
    resource_group_name               = each.value.resource_group_name
    sku                               = each.value.sku
    tags                              = each.value.tags
    customer_managed_key_enabled = each.value.customer_managed_key_enabled !=null ? true: false
    managed_disk_cmk_key_vault_key_id = each.value.customer_managed_key !=null ? data.azurerm_key_vault_key.this[each.key].id : null
    default_storage_firewall_enabled = each.value.default_firewall_enabled 
    access_connector_id = each.value.access_connector_id 
    dynamic "custom_parameters" {
        for_each = each.value.custom_parameters
        content {
            machine_learning_workspace_id = try(custom_parameters.value.machine_learning_workspace_id, null)
            nat_gateway_name = try(custom_parameters.value.nat_gateway_name, null)
            no_public_ip = try(custom_parameters.value.no_public_ip, null)
            private_subnet_name = try(custom_parameters.value.private_subnet_name, null)
            private_subnet_network_security_group_association_id = try(data.azurerm_subnet.private[each.databrick_name].id, null)
            public_ip_name = try(custom_parameters.value.public_ip_name, null)
            public_subnet_name = try(custom_parameters.value.public_subnet_name, null)
            public_subnet_network_security_group_association_id = try(data.azurerm_subnet.public[each.databrick_name].id, null)
            storage_account_name = try(custom_parameters.value.storage_account_name, null)
            storage_account_sku_name = try(custom_parameters.value.storage_account_sku_name, null)
            virtual_network_id = try(data.azurerm_virtual_network.vnet[each.databrick_name].id, null)
            vnet_address_prefix = try(custom_parameters.value.vnet_address_prefix, null)

        }
    }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
    for_each = {
        for k,v in local.databricks : k => v if v.customer_managed_key != null
    }
    workspace_id = azurerm_databricks_workspace.databricks[each.key].id
    key_vault_key_id = data.azurerm_key_vault_key.this[each.key].id
    depends_on = [azurerm_role_assignment.rbac_stg]
}

data "azurerm_databricks_workspace" "this" {
    for_each = local.databricks
    name                = each.value.databrick_name
    resource_group_name = each.value.resource_group_name
    depends_on = [azurerm_databricks_workspace.databricks]
}

resource "azurerm_role_assignment" "rbac_managed_disk" {
    for_each = {
        for k,v in local.databricks : k => v if v.customer_managed_key != null
    }
    scope                = data.azurerm_key_vault.this[each.key].id
    role_definition_name = each.value.customer_managed_key.role_definition_name
    principal_id         = data.azurerm_databricks_workspace.this[each.key].managed_disk_identity[0].principal_id

    lifecycle {
        ignore_changes = [
            principal_id
        ]
    }
}

resource "azurerm_role_assignment" "rbac_stg" {
    for_each = {
        for k,v in local.databricks : k => v if v.customer_managed_key != null
    }
    scope                = data.azurerm_key_vault.this[each.key].id
    role_definition_name = each.value.customer_managed_key.role_definition_name
    principal_id         = data.azurerm_databricks_workspace.this[each.key].storage_account_identity[0].principal_id

    lifecycle {
        ignore_changes = [
            principal_id
        ]
    }
}