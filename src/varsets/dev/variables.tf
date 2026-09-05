variable "resource_groups" {
default = []
}

variable "virtual_networks" {
default = []
}

variable "storage_accounts" {
default = []
}

variable "key_vaults" {
default = []
}

variable "user_assigned_identities" {
default = []
}

variable "private_endpoints" {
default = []
}

variable "private_dns_zones" {
default = []
}

variable "databricks" {
  default = {}
}

variable "databricks_config" {
  default = {}
}

variable "network_security_groups" {
  default = {}
}

variable "access_connectors" {
  default = {}
}