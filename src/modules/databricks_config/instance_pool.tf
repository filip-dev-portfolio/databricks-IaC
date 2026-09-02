resource "databricks_instance_pool" "this" {
    for_each = local.instance_pools

    instance_pool_name = each.value.instance_pool_name
    node_type_id       = each.value.node_size
    min_idle_instances = each.value.min_idle_instances
    max_capacity       = each.value.max_capacity
    idle_instance_autotermination_minutes = each.value.idle_instance_autotermination_minutes

    dynamic "azure_attributes" {
        for_each = each.value.azure_attributes != null ? [each.value.azure_attributes] : []
        content {
            availability = azure_attributes.value.availability
            spot_bid_max_price = azure_attributes.value.spot_bid_max_price
        }
    }

    dynamic "disk_spec" {
        for_each = each.value.disk_spec != null ? [each.value.disk_spec] : []
        content {
            dynamic "disk_type" {
                for_each = disk_spec.value.disk_type != null ? [disk_spec.value.disk_type] : []
                content {
                    azure_disk_volume_type = disk_type.value.azure_disk_volume_type == true ?  disk_type.value.azure_disk_volume_type: null
                }
            }

            disk_count = disk_spec.value.disk_count
            disk_size = disk_spec.value.disk_size
        }
    }
  
}