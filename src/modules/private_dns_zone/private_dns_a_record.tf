resource "azurerm_private_dns_a_record" "dns_a_record" {
    for_each = local.private_dns_a_records

    name                = each.value.dns_a_record_name
    zone_name           = azurerm_private_dns_zone.dns_zone[each.value.dns_zone_name].name
    resource_group_name = each.value.resource_group_name
    ttl                 = each.value.ttl
    records             = each.value.records
}