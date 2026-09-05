resource "azurerm_subnet" "subnet" {
  for_each = local.subnets

  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes       = [each.value.address_prefix]
  service_endpoints      = try(each.value.service_endpoints, [])
  
  dynamic "delegation" {
    for_each = try(each.value.delegations, [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
  depends_on = [azurerm_virtual_network.vnet]
}