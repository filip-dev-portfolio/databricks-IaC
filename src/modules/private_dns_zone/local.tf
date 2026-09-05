locals {
    private_dns_zones = {
        for dns in flatten ([
            for dns_zone in try (var.private_dns_zones, []):merge (
                dns_zone,
                {
                    dns_a_records = try (dns_zone.dns_a_records, [])
                }
            )
        ]): dns.dns_zone_name => dns
    }
}

locals {
    private_dns_zone_vnet_links = {
        for dns_vnet_link in flatten([
            for dns_zone_k, dns_zone_v in local.private_dns_zones: [
                for vnet_link in try(dns_zone_v.virtual_network_links, []): merge(
                    vnet_link,
                    {
                        dns_zone_name = dns_zone_k
                        vnet_link_name = try(vnet_link.vnet_link_name, "vnet_link_${dns_zone_k}")
                        vnet_rg = dns_zone_v.resource_group_name
                    }
                )
            ]
        ]): "${dns_vnet_link.vnet_name}_${dns_vnet_link.vnet_link_name}" => dns_vnet_link
    }
}

locals {
    private_dns_a_records = {
        for dns_a_record in flatten([
            for dns_zone_k, dns_zone_v in local.private_dns_zones: [
                for dns_a_record in try(dns_zone_v.dns_a_records, []): merge(
                    dns_a_record,
                    {
                        dns_zone_name = dns_zone_k
                        resource_group_name = dns_zone_v.resource_group_name
                        dns_a_record_name = dns_a_record.dns_a_record_name
                        ttl = try(dns_a_record.ttl, 3600)
                    }
                )
            ]
        ]): "${dns_a_record.dns_a_record_name}_${dns_a_record.dns_zone_name}" => dns_a_record
    }
}