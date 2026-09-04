data "azurerm_subnet" "subnet" {
  for_each = local.nsg_subnet_associations
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}
