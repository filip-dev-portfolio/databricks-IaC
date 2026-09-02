locals {
    databricks = {
        for databricks_ in flatten([
            for databricks in try(var.databricks, []) : [
                for custom in try(databricks.custom_parameters, []) : merge({
                    databrick_name = databricks.databrick_name
                    infrastructure_encryption_enabled = try(databricks.infrastructure_encryption_enabled, null)
                    location = try(databricks.location, null)
                    managed_resource_group_name =  null
                    network_security_group_rules_required = try(databricks.network_security_group_rules_required, null)
                    public_network_access_enabled = try(databricks.public_network_access_enabled, null)
                    resource_group_name = try(databricks.resource_group_name, null)
                    sku = try(databricks.sku, "standard")
                    tags = try(databricks.tags, null)
                    custom_parameters = try(databricks.custom_parameters, [])
                    customer_managed_key_enabled = try(databricks.customer_managed_key_enabled, null)
                    customer_managed_key = try(databricks.customer_managed_key, null)
                    access_connector_id = try(databricks.access_connector_id, null)
                    default_firewall_enabled = try(databricks.default_firewall_enabled, null)
                },
                databricks
                )
            ]
        ]) : databricks_.databricks_name => databricks_
    }
}

locals {
    databricks_info = {
        for d_net in flatten([
            for d_k, d_v in try(local.databricks, []) : [
                for d_net in try(d_v.custom_parameters, []) : merge({
                    databricks_name = d_v.databrick_name
                    location = d_v.location
                    resource_group_name = try(custom.vnet_rg, d_v.resource_group_name)
                },
                custom
                )
            ]
        ]): d_net.databrick_name => d_net
    }
}
