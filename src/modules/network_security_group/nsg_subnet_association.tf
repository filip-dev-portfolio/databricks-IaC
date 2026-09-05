resource "azurerm_network_security_group_association" "nsg" {
    for_each = local.nsg_subnet_associations
    network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_name].id
    subnet_id                 = data.azurerm_subnet.subnet[each.value.asso_key].id
    depends_on = [data.azurerm_subnet.subnet,azurerm_network_security_group.nsg]
}