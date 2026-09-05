locals {
    key_vaults = {
        for kv_ in flatten(
            [
                for kv in try(var.key_vaults, []): merge(
                    {
                        purge_protection_enabled = try(kv.purge_protection_enabled, false)
                        enable_for_disk_encryption = try(kv.enable_for_disk_encryption, false)
                        enable_for_rbac_authorization = try(kv.enable_for_rbac_authorization, true)
                        soft_delete_retention_days = try(kv.soft_delete_retention_days, 90)
                        network_acls = []
                        customer_managed_keys = []

                    },kv
                )
            ]
        ): kv_.key_vault_name => kv_
    }
}

locals {
    kv_rbac = {
        for kv_rbac_assign in flatten([
            for kv in local.key_vaults: [
                for rbac_assign in try(kv.rbac, []): merge(
                    {
                        key_vault_name = kv.key_vault_name
                        object_id = (try(rbac_assign.type, null)=="user_assigned_identity" ?
                        data.azurern_user_assigned_identity.uai["${rbac_assign.object_name}-${rbac_assign.role_definition_id}"].principal_id : rbac_assign.object_id)
                        role_definition_name = rbac_assign.role_definition_name
                    }, rbac_assign
                )
            ]
        ]): replace("${kv_rbac_assign.key_vault_name}-${kv_rbac_assign.object_name}-${kv_rbac_assign.role_definition_id}", " ", "-") => kv_rbac_assign
    }
}

locals {
    customer_managed_keys = {
        for keys in flatten([
            for k,v in local.key_vaults: [
                for key in try(v.customer_managed_keys, []): merge(
                    {
                        kv_name = k
                    }, key
                )
            ]
        ]): "${keys.kv_name}-${keys.name}" => keys
    }
}

locals {
    object_names = flatten ([
        for kv in local.key_vaults: [
            for p in try(kv.rbac, []): merge (
                {
                    resource_group_name = kv.resource_group_name
                    type = "azuread_user"
                }, p
            )
        ]
    ])
}