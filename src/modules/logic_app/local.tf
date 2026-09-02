locals {
    logic_apps = {
        for w in var.logic_apps : w.var.logic_app_name => merge ({
            https_only = try(w.https_only, true)
            ftp_publish_basic_authentication_enabled = try(w.ftp_publish_basic_authentication_enabled, false)
            scm_publish_basic_authentication_enabled = try(w.scm_publish_basic_authentication_enabled, false)
            functions_worker_runtime = try(w.functions_worker_runtime, "dotnet")
            website_node_default_version = try(w.website_node_default_version, "20")
            website_contentovervnet = try(w.website_contentovervnet, 1)
            always_on = try(w.always_on, false)
            app_scale_limit=try(w.app_scale_limit, 0)
            dontnet_framework_version = try(w.dontnet_framework_version, "v6.0")
            elastic_instance_minimum = try(w.elastic_instance_minimum, 1)
            ftps_state = try(w.ftps_state, "FtpsOnly")
            health_check_path = try(w.health_check_path, "")
            http2_enabled = try(w.http2_enabled, false)
            linux_fx_version = try(w.linux_fx_version, "")
            min_tls_version = try(w.min_tls_version, "1.2")
            runtime_scale_monitoring_enabled = try(w.runtime_scale_monitoring_enabled, true)
            scm_min_tls_version = try(w.scm_min_tls_version, "1.2")
            scm_type = try(w.scm_type, "None")
            scm_use_main_ip_restriction = try(w.scm_use_main_ip_restriction, false)
            use_32_bit_worker_process = try(w.use_32_bit_worker_process, false)
            vnet_route_all_enabled = try(w.vnet_route_all_enabled, true)
            public_network_access= try(w.public_network_access, "Disabled")
            websockets_enabled = try(w.websockets_enabled,false)
            app_service_plan_name = try(w.app_service_plan_name, "")
            pre_warmed_instance_count = try(w.pre_warmed_instance_count, 1)

        }, w)
    }
}

locals {
    logic_rbac = {
        for lg_rbac_assign in flatten ([
            for lg in local.logic_apps : [
                for rbac_assign in try (lg.rbac, []): merge (
                    {
                        logic_app_name = lg.logic_app_name
                        object_id = azurerm_logic_app_standard.logic_app[lg.logic_app_name].identity[0].principal_id
                        role_definition_name = rbac_assign.role_definition_name
                        resource_group_name = rbac_assign.stg_resource_group_name
                        scope_type = try(rbac_assign.scope_type, null)
                    }, rbac_assign
                )
            ]
        ]): replace("${lg_rbac_assign.logic_app_name}-${lg_rbac_assign.resource_name}-${lg_rbac_assign.role_definition_name}", " ", "") => lg_rbac_assign
    }
}