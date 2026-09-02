resource "databricks_cluster" "cluster" {
    for_each = local.cluster_config

    cluster_name            = each.value.cluster_name
    spark_version           = data.databricks_spark_version.sv[each.key].id
    node_type_id            = each.value.node_size
    autotermination_minutes = each.value.autotermination_minutes
    data_security_mode       = each.value.data_security_mode
    runtime_engine          = each.value.runtime_engine
    policy_id               = (
        each.value.policy_name != null ? databricks_cluster_policy.policy["${each.value.policy_name}"].id : null
        )

    dynamic "autoscale" {
        for_each = each.value.autoscale != [] ? [each.value.autoscale] : []
        content {
            min_workers = autoscale.value.min_value
            max_workers = autoscale.value.max_value
        }
    }

    dynamic "azure_attributes" {
        for_each = each.value.azure_attributes != null ? [each.value.azure_attributes] : []
        content {
            availability = azure_attributes.value.availability
            spot_bid_max_price = azure_attributes.value.spot_bid_max_price

        }
    }
}