resource "databricks_cluster_policy" "policy" {
    for_each = local.policies

    name = each.value.name
    definition = jsonencode(each.value.policy)
}