module "resource_group" {
    source = "../../modules/resource_group"
    resource_groups = try(var.resource_groups, [])
    depends_on = []
}

module "virtual_network" {
    source = "../../modules/virtual_network"
    virtual_networks = try(var.virtual_networks, [])
    depends_on = []
}

module "storage_account" {
    source = "../../modules/storage_account"
    storage_accounts = try(var.storage_accounts, [])
    depends_on = []
}

module "key_vault" {
    source = "../../modules/key_vault"
    key_vaults = try(var.key_vaults, [])
    depends_on = []
}

module "user_assigned_identity" {
    source = "../../modules/user_assigned_identity"
    user_assigned_identities = try(var.user_assigned_identities, [])
    depends_on = []
}

module "private_endpoint" {
    source = "../../modules/private_endpoint"
    private_endpoints = try(var.private_endpoints, [])
    depends_on = []
}

module "databricks" {
    source = "../../modules/databricks"
    databricks = try(var.databricks, [])
    depends_on = []
}

module "databricks_config" {
    source = "../../modules/databricks_config"
    databricks_config = try(var.databricks_config, [])
    depends_on = []
}

module "network_security_groups" {
    source = "../../modules/network_security_groups"
    network_security_groups = try(var.network_security_groups, [])
    depends_on = []
}

module "access_connectors" {
    source = "../../modules/access_connectors"
    access_connectors = try(var.access_connectors, [])
    depends_on = []
}