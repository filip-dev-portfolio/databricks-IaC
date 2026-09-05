resource "databricks_sql_endpoint" "this" {
    for_each = local.sql_endpoints
    name = each.value.name
    cluster_size = each.value.cluster_size
    min_num_clusters = each.value.min_num_clusters
    max_num_clusters = each.value.max_num_clusters
    auto_stop_mins = each.value.auto_stop_mins
    enable_serverless_compute = each.value.enable_serverless_compute
}