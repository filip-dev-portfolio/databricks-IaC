data "azurerm_databricks_workspace" "dw" {
    count = var.databricks_config.databricks_workspace_name != "" ? 1 : 0
    name                = var.databricks_config.databricks_workspace_name
    resource_group_name = var.databricks_config.resource_group_name
}

data "azurerm_key_vault" "kv" {
    for_each = {
        for k, v in local.scopes : k => v if v.kv_name != ""
    }
    name                = each.value.kv_name
    resource_group_name = each.value.resource_group_name
}

data "databricks_spark_version" "sv" {
    for_each = local.cluster_config
    long_term_support = each.value.long_term_support
}