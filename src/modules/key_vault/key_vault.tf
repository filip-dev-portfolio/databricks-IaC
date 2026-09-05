resource "azurerm_key_vault" "kv" {
    for_each = local.key_vaults

    name = each.value.key_vault_name
    location = each.value.location
    resource_group_name = each.value.resource_group_name
    tenant_id = data.azurerm_client_config.current.tenant_id
    sku_name = each.value.sku_name
    purge_protection_enabled = each.value.purge_protection_enabled
    enabled_for_disk_encryption = each.value.enable_for_disk_encryption
    enable_rbac_authorization = each.value.enable_for_rbac_authorization
    soft_delete_retention_days = each.value.soft_delete_retention_days

    dynamic "network_acls" {
        for_each = each.value.network_acls
        content {
            bypass = network_acls.value.bypass
            ip_rules = network_acls.value.ip_rules
            default_action = network_acls.value.default_action
        }
    }
}