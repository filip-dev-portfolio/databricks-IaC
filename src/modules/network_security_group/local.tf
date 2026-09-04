locals {
    nsgs = {
        for nsg in flatten([
            for nsg_ in try(var.network_security_groups, []): merge([
                {
                    location = nsg_.location
                    nsg_name = nsg_.nsg_name
                    resource_group_name = nsg_.resource_group_name
                    subnet_associations = []

                }, nsg_
            ])
        ]): nsg.nsg_name => nsg
    }
}

locals {
    nsg_rules = {
        for rule in flatten([
            for nsg_k, nsg_v in try(local.nsgs, {}): [
                for rule_ in try(nsg_v.nsg_rules, []): merge([
                    {
                        destination_address_prefix = null
                        destination_address_prefixes = null
                        destination_application_security_group_ids = null
                        destination_port_range     = null
                        destination_port_ranges    = null
                        source_address_prefix      = null
                        source_address_prefixes    = null
                        source_application_security_group_ids = null
                        source_port_range          = null
                        source_port_ranges         = null
                        network_security_group_name = azurerm_network_security_group.nsg[nsg_k].name
                        resource_group_name = nsg_v.resource_group_name
                        rule_key = "${nsg_k}-${rule_.rule_name}"
                    }, rule_
                ])
            ]
        ]): rule.rule_key => rule
    }
}

locals {
    nsg_subnet_associations = {
        for sub_asso in flatten([
            for nsg_k, nsg_v in local.nsgs:[
                for association in nsg_v.subnet_associations: [
                    for subnet in association.subnets : merge({
                        asso_key = "${nsg_v.nsg_name}-${association.vnet_name}-${subnet}"
                        nsg_name = azurerm_network_security_group.nsg[nsg_k].name
                        resource_group_name = nsg_v.resource_group_name
                        subnet_name = subnet
                        vnet_name = association.vnet_name
                    })
                ]
            ]
        ]): sub_asso.asso_key => sub_asso
    }
}