resource "azurerm_user_assigned_identity" "uai" {
  for_each = local.user_assigned_identities

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group
}