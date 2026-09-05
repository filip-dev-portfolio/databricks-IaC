resource "azurerm_private_dns_zone" "private_dns_zone" {
    for_each = local.private_dns_zones

    name                = each.key
    resource_group_name = each.value.resource_group_name
}