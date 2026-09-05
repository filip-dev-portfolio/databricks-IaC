locals {
    databricks_workspace_name = data.azurerm_databricks_workspace.dw[0].name
    databricks_workspace_id   = data.azurerm_databricks_workspace.dw[0].id
    databricks_workspace_host  = data.azurerm_databricks_workspace.dw[0].workspace_url
}

locals {
    group_permission = {
        for g in try(var.databricks_config.groups, []) : g.name => merge(
            {
                allow_cluster_create = false
                databricks_sql_access = false
                workspace_access     = false
            },
            g
        )
    }
}

locals{
    scopes = {
        for s in try(var.databricks_config.scopes, []) : s.name => merge(
            {
                kv_name             = ""
                databricks_name = ""
                resource_group_name  = try(s.kv_rg, var.databricks_config.resource_group_name)
            },
            s
        )
    }
}

locals {
    cluster_config = {
        for config in flatten (
            [
                for c in try(var.databricks_config.cluster_config, []) : merge (
                    {
                        long_term_support = true
                        databricks_workspace = var.databricks_config.databricks_workspace
                        resource_group_name = var.databricks_config.resource_group_name
                        cluster_name = c.cluster_name
                        local_disk = true
                        autotermination_minutes = 20
                        autoscale = []
                        min_value = null
                        instance_pool_name = null
                        instance_pool = null
                        policies = []
                        policy_name = null
                        permissions = null
                        runtime_engine = null

                    },
                    c
                )
            ]
        ): "${config.cluster_name}" => config
    }
}

locals {
    policies = {
        for pol in flatten (
            [
                for p in try(var.databricks_config.policies, []) : merge (
                    {
                        databricks_workspace = var.databricks_config.databricks_workspace
                        permissions = null
                    },
                    p
                )
            ]
        ): "${pol.name}" => pol
    }
}

locals {
    instance_pools = {
        for pool in flatten (
            [
                for p in try(var.databricks_config.instance_pools, []) : merge (
                    {
                        databricks_workspace = var.databricks_config.databricks_workspace
                        idle_instance_autotermination_minutes = 20
                        max_capacity = 2
                    },
                    p
                )
            ]
        ): pool.instance_pool_name => pool
    }
}

locals {
    sql_endpoints = {
        for sql in flatten (
            [
                for s in try(var.databricks_config.sql_endpoints, []) : merge (
                    {
                        databricks_workspace = var.databricks_config.databricks_workspace
                        name = s.name
                        max_num_clusters = s.max_num_clusters
                        cluster_size = s.cluster_size
                    },
                    s
                )
            ]
        ): "${sql.name}" => sql
    }
}