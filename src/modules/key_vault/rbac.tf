resource "azurerm_role_assignment" "kv_rbac" {
    for_each = local.kv_rbac
    scope = azurerm_key_vault.kv[each.value.key_vault_name].id
    role_definition_name = each.value.role_definition_name
    principal_id = each.value.object_id
    
    depends_on = [azurerm_key_vault.kv]
}