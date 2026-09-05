locals {
  vnets = {
    for vnet in flatten([
        for _vnet in try(var.virtual_networks, []) : merge (
            {
                # overrideable properties
                resource_group = _vnet.resource_group
                location = _vnet.location
                address_space = _vnet.address_space
                vnet_name = _vnet.name
            },
            _vnet
        )
    ]

    ): vnet.vnet_name => vnet
  }
}

locals {
    subnets = {
        for subnet in flatten (
            [
            for vnet_k, vnet_v in local.vnets : [
                for subnet_ in try(vnet_v.subnets, []) : merge (
                    {
                        # overrideable properties
                        resource_group = vnet_v.resource_group
                        location = vnet_v.location
                        address_prefix = subnet_.address_prefix
                        subnet_name = subnet_.name
                        vnet_name = vnet_k
                        delegations = try(subnet_.delegations, [])
                        service_endpoints = try(subnet_.service_endpoints, [])
                    },
                    subnet_
                )
            ]
            ]
        ): "${subnet.vnet_name}-${subnet.subnet_name}" => subnet
    }
}