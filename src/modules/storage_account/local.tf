locals {
    storage_accounts = {
        for storage in flatten([
            for sta in try (var.storage_accounts, []) : merge(
                {
                    name = sta.name
                    resource_group_name = sta.resource_group_name
                    location = sta.location
                    account_tier = sta.account_tier
                    account_replication_type = sta.account_replication_type
                    identity = null
                    customer_managed_key = null
                    change_feed_enabled = true
                    change_feed_retention_in_days = 7
                    last_access_time_enabled = false
                    versioning_enabled = true
                    container_delete_retention_policy_days = 30
                    delete_retention_policy_days = 30
                    delete_retention_policy_permanent_delete_enabled = false
                    restore_policy_days = 6
                    file_share_configs = []
                    share_retention_policy_days = 30
                },
                sta
            )
        ]) : storage.name => storage
    }
}

locals {
    sta_containers = {
        for sta_container_ in flatten([
            for sta_k, sta_v in try(local.storage_accounts, []): [
                for sta_container in try (sta_v.containers, []) : merge(
                    {
                        name = sta_container.name
                        storage_account_name = sta_v.name
                    },
                    sta_container
                )
            ]
        ]): "${sta_container_.storage_account_name}-${sta_container_.name}" => sta_container_
    }
}

locals {
    network_rules = {
        for network_rule_ in flatten([
            for sta_k, sta_v in try(local.storage_accounts, []): [
                for network_rule in try (sta_v.network_rules, []) : merge(
                    {
                        storage_account_name = sta_v.name
                    },
                    network_rule
                )
            ]
        ]): network_rule_.storage_account_name => network_rule_
    }
}

locals {
    file_shares = {
        for file_share_config_ in flatten([
            for sta_k, sta_v in try(local.storage_accounts, []): [
                for c in try (sta_v.file_share_configs, []) : [
                     for file_share in try (c.file_shares, []) : merge(
                        {
                            name = file_share.name
                            resource_group_name = c.resource_group_name
                            storage_account_name = sta_v.name
                        },
                        file_share
                    )
                ]
            ]
        ]): "${file_share_config_.storage_account_name}-${file_share_config_.name}" => file_share_config_
    }
}

locals {
    network_rules = {
        for network_rule_ in flatten([
            for sta_k, sta_v in try(local.storage_accounts, []): [
                for network_rule in try (sta_v.network_rules, []) : merge(
                    {
                        storage_account_name = sta_v.name
                    },
                    network_rule
                )
            ]
        ]): network_rule_.storage_account_name => network_rule_
     }
}

locals {
    access_connector = {
        for access_connector_ in flatten([
            for net_rule_k, net_rule_v in try(local.network_rules, []): [
                for link_access in try (net_rule_v.private_link_access, []) : merge(
                    {
                        storage_account_name = net_rule_v.name
                        access_connector_name = try(link_access.access_connector_name, null)
                        resource_group_name = try(link_access.resource_group_name, net_rule_v.resource_group_name)
                    },
                    link_access
                )
            ]
        ]): access_connector_.storage_account_name => access_connector_

    }
}