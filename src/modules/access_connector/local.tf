locals {
    access_connectors = {
        for access_connectors_ in flatten([
            for ac_v in try(local.access_connectors, []) : merge(
                ac_v,
                {
                    access_connector_name = ac_v.access_connector_name
                    location = ac_v.location
                    resource_group_name = ac_v.resource_group_name
                }
            )
        ]): access_connectors_.access_connector_name => access_connectors_
    }
}