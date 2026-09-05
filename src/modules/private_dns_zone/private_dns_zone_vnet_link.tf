resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
    for_each = local.private_dns_zone_vnet_links

    name                = each.value.vnet_link_name
    resource_group_name = each.value.vnet_rg
    private_dns_zone_name = each.value.dns_zone_name
    virtual_network_id  = data.azurerm_virtual_network.vnet[each.key].id


}