resource "azurerm_private_endpoint" "pe" {
    for_each = local.private_endpoints

    name                = each.value.pe_name
    location            = each.value.location
    resource_group_name = each.value.resource_group_name
    custom_network_interface_name = each.value.custom_network_interface_name
    subnet_id          = data.azurerm_subnet.subnet[each.value.pe_name].id

    private_service_connection {
        name                           = "${each.value.pe_name}-psc"
        is_manual_connection            = each.value.is_manual_connection
        private_connection_resource_id  = data.azurerm_key_vault.kv[each.value.kv_name].id
        subresource_names               = each.value.subresource_names
        request_message                 = each.value.is_manual_connection ? "Please approve this connection." : null
    }

    dynamic "private_dns_zone_group" {
        for_each = each.value.private_dns_zone_groups
        content {
            name = "default"
            private_dns_zone_ids = [data.azurerm_private_dns_zone.pdz["${private_dns_zone_group.value.private_dns_zone_name}-${each.key}"].id]
        }
    }
}