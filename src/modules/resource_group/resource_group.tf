resource "azurerm_resource_group" "rg" {
  for_each = local.resource_groups

  name     = each.value.resource_group_name
  location = each.value.location
}