resource "azurerm_role_assignment" "rbac" {
    for_each = local.logic_rbac

    scope = (each.value.scope_type == "storage_account" ? try(data.azurerm_storage_account.rbac_sta[each.key].id,null): null)
    principal_id = each.value.object_id
    role_definition_name = each.value.role_definition_name
}