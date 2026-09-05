resource "azurerm_storage_account" "sta" {
    for_each = try(local.storage_accounts, {})
    name                     = each.value.name
    resource_group_name      = each.value.resource_group_name
    location                 = each.value.location
    account_tier             = each.value.account_tier
    account_replication_type = each.value.account_replication_type
    is_hns_enabled           = lookup(each.value, "is_hns_enabled", null)
    tags                     = lookup(each.value, "tags", null)

    dynamic "blob_properties" {
        for_each = each.value.is_hns_enabled == true ? [1] : []
        content {
            change_feed_enabled = each.value.change_feed_enabled
            change_feed_retention_in_days = each.value.change_feed_retention_in_days
            last_access_time_enabled = each.value.last_access_time_enabled
            versioning_enabled = each.value.versioning_enabled
            container_delete_retention_policy {
                days = each.value.container_delete_retention_policy_days
            }
            delete_retention_policy {
                days = each.value.delete_retention_policy_days
                permanent_delete_enabled = each.value.delete_retention_policy_permanent_delete_enabled
            }
            restore_policy {
                days = each.value.restore_policy_days
            }
    }
}
    dynamic "share_properties" {
            for_each = each.value.file_share_configs != null ? [1] : []
            content {
                retention_policy {
                    days = each.value.share_delete_retention_policy_days
                }
            }
        }

    dynamic "azure_files_authentication" {
        for_each = each.value.directory_type == "AADKERB" ? [1] : []
        content {
            directory_type = each.value.directory_type
            active_directory {
                domain_name = each.value.domain_name
                domain_sid = each.value.domain_sid
                domain_guid = each.value.domain_guid
                forest_name = each.value.forest_name
                storage_sid = each.value.storage_sid
                netbios_domain_name = each.value.netbios_domain_name

            }
        }
    }

    dynamic "identity" {
        for_each = each.value.identity != "SystemAssigned" ? [1] : []
        content {
            type = "SystemAssigned"
        }
    }
    dynamic "identity" {
        for_each = each.value.user_assigned_identity != null ? [1] : []
        content {
        identity_ids = [data.azurerm_user_assigned_identity.uai[each.key].id]
        type = "UserAssigned"
        }
    }