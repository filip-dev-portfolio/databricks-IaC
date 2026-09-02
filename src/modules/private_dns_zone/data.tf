data "azurerm_virtual_network" "vnet" {
    for_each = local.private_dns_zone_vnet_links

    name                = each.value.vnet_name
    resource_group_name = each.value.vnet_rg
}