resource "azurerm_virtual_network" "vnet" {
  for_each = local.vnets

  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = each.value.resource_group
  address_space       = each.value.address_space

  tags = try(each.value.tags, {})
}