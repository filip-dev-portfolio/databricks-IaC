resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsgs

  name                = each.value.nsg_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

}