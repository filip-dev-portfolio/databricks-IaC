resource "databricks_secret_acl" "sa" {
    for_each = local.group_permission
    principal = databricks_group.ds[each.key].display_name
    permission = each.value.permission
    scope = databricks_secret_scope.ds[each.key].name
}