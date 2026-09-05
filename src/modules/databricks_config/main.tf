resource "databricks_workspace_conf" "workspace_conf" {
    custom_config = {"enableipaccesslist" = true}
}

resource "databricks_ip_access_list" "ip_access_list" {
    label = var.databricks_config.ip_access_list.label
    list_type = var.databricks_config.ip_access_list.list_type
    ip_addresses = var.databricks_config.ip_access_list.ip_addresses
    depends_on = [databricks_workspace_conf.workspace_conf]
}

resource "databricks_group" "ds" {
    for_each = local.group_permission
    display_name = each.value.name
    allow_cluster_create = each.value.allow_cluster_create
    databricks_sql_access = each.value.databricks_sql_access
    workspace_access = each.value.workspace_access
    }

resource "databricks_secret_acl" "sa" {
    for_each = local.group_permission
    principal = databricks_group.ds[each.key].display_name
    permission = each.value.permission
    scope = databricks_secret_scope.ds[each.key].name
}    