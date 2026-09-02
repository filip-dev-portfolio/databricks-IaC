data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "uai" {
for_each = {
    for v in local.object_names: "${v.object_name}-${v.role_definition_name}" => v if v.type == "user_assigned_identity"
    }
    name = each.value.object_name
    resource_group_name = each.value.resource_group_name
}