resource "databricks_group" "ds" {
    for_each = local.group_permission

    display_name = each.value.name
    allow_cluster_create = each.value.allow_cluster_create
    databricks_sql_access = each.value.databricks_sql_access
    workspace_access = each.value.workspace_access
}