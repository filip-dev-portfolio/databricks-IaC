data "azurerm_resource_group" "rg" {
    for_each = local.access_connectors
    name     = each.value.resource_group_name
}