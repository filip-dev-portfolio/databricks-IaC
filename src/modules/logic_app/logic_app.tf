resource "azurerm_service_plan" "service_plan" {
  for_each = local.logic_apps

  name = each.value.app_service_plan.service_plan_name
  location = each.value.app_service_plan.location
  resource_group_name = each.value.app_service_plan.resource_group_name
  sku_name = each.value.app_service_plan.sku_name
  worker_count = try(each.value.app_service_plan.worker_count,1)
  os_type = try(each.value.app_service_plan.os_type, "Windows")
  maximum_elastic_worker_count = try(each.value.app_service_plan.maximum_elastic_worker_count, 20)
  per_site_scaling_enabled = try(each.value.app_service_plan.per_site_scaling_enabled, false)
  premium_plan_auto_scale_enabled = try(each.value.app_service_plan.premium_plan_auto_scale_enabled, false)
  zone_balancing_enabled = try(each.value.app_service_plan.zone_balancing_enabled,false)
}

resource "azurerm_logic_app_standard" "logic_app" {
    for_each = local.logic_apps

    name = each.value.logic_app_name
    location = each.value.location
    resource_group_name = each.value.resource_group_name
    app_service_plan_id = azurerm_service_plan.service_plan[each.key].id
    storage_account_name = each.value.storage_account_name
    storage_account_access_key = data.azurerm_storage_account.sta[each.key].primary_access_key
    storage_account_share_name = each.value.storage_account_share_name
    https_only = each.value.https_only
    virtual_network_subnet_id = data.azurerm_subnet.logic_app_subnet[each.key].id
    ftp_publish_basic_authentication_enabled = each.value.ftp_publish_basic_authentication_enabled
    public_network_access = each.value.public_network_access
    scm_publish_basic_authentication_enabled = each.value.scm_publish_basic_authentication_enabled

    app_settings = {
      "FUNCTION_WORKER_RUNTIME" = each.value.functions_worker_runtime
      "WEBSITE_NODE_DEFAULT_VERSION" = each.value.website_node_default_version
      "WEBSITE_CONTENTOVERVNET" = each.value.website_contentovervnet
      "minTlsVersion" = try(each.value.min_tls_version,"1.2")
    }
    site_config {
      always_on = each.value.always_on
      app_scale_limit = each.value.app_scale_limit
      dotnet_framework_version = each.value.dotnet_framework_version
      elastic_instance_minimum = each.value.elastic_instance_minimum
      ftps_state = each.value.ftps_state
      health_check_path = each.value.health_check_path
      http2_enabled = each.value.ttp2_enabled
      linux_fx_version = each.value.linux_fx_version
      pre_warmed_instance_count = each.value.pre_warmed_instance_count
      runtime_scale_monitoring_enabled = each.value.runtime_scale_monitoring_enabled
      scm_min_tls_version = each.value.scm_min_tls_version
      scm_type = each.value.scm_type
      scm_use_main_ip_restriction = each.value.scm_use_main_ip_restriction
      use_32_bit_worker_process = each.value.use_32_bit_worker_process
      vnet_route_all_enabled = each.value.vnet_route_all_enabled
      websockets_enabled = each.value.websockets_enabled
    }
    dynamic "identity" {
      for_each = each.value.user_assigned_identity !=null ? [1]:[]
      content {
        identity_ids = [
            data.azurerm_user_assigned_identity.uai[each.key].id
        ]
        type = "SystemAssigned, UserAssigned"
      }
    }

    lifecycle {
      ignore_changes = [ app_settings ]
    }
    depends_on = [ azurerm_service_plan.service_plan ]
}