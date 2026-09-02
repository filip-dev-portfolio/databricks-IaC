resource "databricks_permissions" "cluster_permissions" {
    for_each = {
        for k, v in local.cluster_config : k => v if v.permissions != null
    }
    cluster_id = databricks_cluster.cluster[each.key].id
    dynamic "access_control" {
        for_each = each.value.permissions
        content {
            group_name = lookup(access_control.value, "group_name", null) !=null ? access_control.value.group_name : null
            user_name = lookup(access_control.value, "user_name", null) !=null ? access_control.value.user_name : null
            permission_level = access_control.value.permission_level
        }
    }
}

resource "databricks_permissions" "policy_permissions" {
    for_each = {
        for k, v in local.policies : k => v if v.permissions != null
    }
    cluster_policy_id = databricks_cluster_policy.policy[each.key].id
    dynamic "access_control" {
        for_each = each.value.permissions
        content {
            group_name = lookup(access_control.value, "group_name", null) !=null ? access_control.value.group_name : null
            user_name = lookup(access_control.value, "user_name", null) !=null ? access_control.value.user_name : null
            permission_level = access_control.value.permission_level
        }
    }
}