locals {
    private_endpoints = {
        for pep in flatten([
            for pe in try(var.var.private_endpoints, []) : merge(
                {
                    location = pe.location
                    pe_name = pe.pe_name
                    resource_group_name = pe.resource_group_name
                    custom_network_interface_name = pe.custom_network_interface_name
                    is_manual_connection = try(pe.is_manual_connection, null)
                    kv_name = null
                    subresource_names = try(pe.subresource_names, [])
                    pe_nic_name = try((pe.custom_network_interface_name != null ? pe.custom_network_interface_name : pe.pe_nic_name), null)
                }, pe
            )
        ]): pep.pe_name => pep
    }
}

locals {
    private_dns_zone = {
        for pdz in flatten([
            for pe_k, pe_v in local.private_endpoints : [
                for dns_zone_group in pe_v.private_dns_zone_groups : merge(
                    {
                        pe_name = pe_k
                        private_dns_zone_rg = pe_v.resource_group_name
                    }, dns_zone_group
                )
            ]
        ]): "${pdz.private_dns_zone_name}-${pdz.pe_name}" => pdz
    }
}