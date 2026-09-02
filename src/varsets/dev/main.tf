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

module "private_dns_zone" {
    source = "../../modules/private_dns_zone"
    private_dns_zones = try(var.private_dns_zones, [])
    depends_on = []
}