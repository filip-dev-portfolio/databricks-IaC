# Azure Data Platform Terraform

Terraform repository for deploying and managing the Azure Data Platform and Azure Databricks infrastructure.

The repository follows a **module + varset architecture**:

- Terraform modules contain reusable infrastructure logic.
- Environment-specific configuration is stored in JSON varsets.
- Each resource has a dedicated Terraform module.
- Each resource has a corresponding environment-specific varset.
- Terraform state is stored remotely in Azure Storage.
- The current environment is `dev`.

---

## Table of Contents

- [Repository Structure](#repository-structure)
- [Architecture Overview](#architecture-overview)
- [Azure Resources](#azure-resources)
- [Networking](#networking)
- [Terraform State](#terraform-state)
- [Modules](#modules)
- [Varsets](#varsets)
- [Databricks Configuration](#databricks-configuration)
- [Cluster Configuration](#cluster-configuration)
- [Cluster Policies](#cluster-policies)
- [Job and All-Purpose Clusters](#job-and-all-purpose-clusters)
- [Environment Separation](#environment-separation)
- [Naming Convention](#naming-convention)
- [Terraform Workflow](#terraform-workflow)
- [Adding a New Resource](#adding-a-new-resource)
- [Adding a New Environment](#adding-a-new-environment)
- [Security](#security)
- [Resource Inventory](#resource-inventory)
- [Design Principles](#design-principles)

---

# Repository Structure

The repository is organized under the `src` directory.

```text
.
└── src/
    ├── modules/
    │   ├── <resource-name>/
    │   ├── <resource-name>/
    │   ├── <resource-name>/
    │   └── ...
    │
    └── varsets/
        └── dev/
            ├── <resource-name>_dev.auto.tfvars.json
            ├── <resource-name>_dev.auto.tfvars.json
            ├── <resource-name>_dev.auto.tfvars.json
            └── ...
```

Each resource has two main components:

```text
Terraform module
    └── src/modules/<resource-name>/

Environment configuration
    └── src/varsets/dev/<resource-name>_dev.auto.tfvars.json
```

The Terraform module contains the reusable infrastructure implementation.

The varset contains the environment-specific configuration.

---

# Architecture Overview

The high-level Azure architecture is:

```text
Azure Subscription
│
├── rg-data-platform-dev
│   │
│   ├── vnet-data-platform-dev
│   │   │
│   │   ├── pe-subnet
│   │   │   ├── databricks-dev-pep
│   │   │   ├── kv-dev-pep
│   │   │   └── sta-dev-pep
│   │   │
│   │   ├── management-subnet
│   │   │
│   │   ├── subnet-data-platform-dev-public
│   │   │   └── subnet-data-platform-dev-public-nsg
│   │   │
│   │   └── subnet-data-platform-dev-private
│   │       └── subnet-data-platform-dev-private-nsg
│   │
│   ├── dbw-data-platform-dev
│   │
│   ├── ac-data-platform-dev
│   │
│   ├── kv-data-platform-dev
│   │   ├── databrickskey
│   │   └── storageaccountkey
│   │
│   └── stlandingareadev
│
└── rg-tfworkspace-dev
    │
    └── stdataingestiondev
        └── state
            └── terraform.tfstate
```

---

# Azure Resources

## Resource Group

The main Data Platform resource group is:

```text
rg-data-platform-dev
```

This resource group contains the primary Azure Data Platform infrastructure.

---

## Storage Account

The storage account used for the Unity Catalog data area is:

```text
stlandingareadev
```

The Databricks Access Connector provides access to this storage account.

The storage account is integrated with the private networking architecture through a private endpoint.

---

## Key Vault

The Key Vault used for customer-managed keys is:

```text
kv-data-platform-dev
```

The following keys are stored in the Key Vault:

```text
databrickskey
storageaccountkey
```

These keys are used as customer-managed keys (CMKs) for the platform resources.

The Key Vault is accessed through the user-assigned managed identity:

```text
keyvault-dev-identity-01
```

---

## Managed Identity

The user-assigned managed identity is:

```text
keyvault-dev-identity-01
```

The identity is used to provide Azure resources with controlled access to the Key Vault.

The access model is:

```text
Azure Resource
      │
      ▼
User Assigned Managed Identity
      │
      ▼
Key Vault
      │
      ▼
Customer Managed Key
```

Access should follow the principle of least privilege.

---

## Azure Databricks

The Azure Databricks workspace is:

```text
dbw-data-platform-dev
```

The workspace is integrated into the Data Platform networking and security architecture.

Databricks resources are managed using Terraform modules and JSON varsets.

The Databricks configuration can include:

- Clusters
- Cluster policies
- Instance pools
- Secret scopes
- Secret ACLs
- Groups
- Permissions
- SQL endpoints

---

## Databricks Access Connector

The Databricks Access Connector is:

```text
ac-data-platform-dev
```

The Access Connector provides the identity used by Azure Databricks to access Azure resources.

The Access Connector has private access to:

```text
stlandingareadev
```

The intended access flow is:

```text
Azure Databricks
       │
       ▼
ac-data-platform-dev
       │
       ▼
Private connectivity
       │
       ▼
stlandingareadev
```

---

# Networking

## Virtual Network

The main Virtual Network is:

```text
vnet-data-platform-dev
```

The VNet contains the following subnets:

```text
vnet-data-platform-dev
│
├── pe-subnet
├── management-subnet
├── subnet-data-platform-dev-public
└── subnet-data-platform-dev-private
```

---

## Subnets

### Private Endpoint Subnet

```text
pe-subnet
```

This subnet is used for Azure Private Endpoints.

Private endpoints deployed into this subnet include:

```text
databricks-dev-pep
kv-dev-pep
sta-dev-pep
```

### Management Subnet

```text
management-subnet
```

This subnet is reserved for management-related infrastructure and services.

### Public Subnet

```text
subnet-data-platform-dev-public
```

Associated Network Security Group:

```text
subnet-data-platform-dev-public-nsg
```

### Private Subnet

```text
subnet-data-platform-dev-private
```

Associated Network Security Group:

```text
subnet-data-platform-dev-private-nsg
```

---

## Network Security Groups

The environment contains two primary Network Security Groups:

```text
subnet-data-platform-dev-public-nsg
subnet-data-platform-dev-private-nsg
```

They are associated with:

| Network Security Group | Subnet |
|---|---|
| `subnet-data-platform-dev-public-nsg` | `subnet-data-platform-dev-public` |
| `subnet-data-platform-dev-private-nsg` | `subnet-data-platform-dev-private` |

Network security rules should be managed through Terraform rather than manually through the Azure Portal.

---

## Private Endpoints

The environment contains the following private endpoints:

| Private Endpoint | Target Service |
|---|---|
| `databricks-dev-pep` | Azure Databricks |
| `kv-dev-pep` | Azure Key Vault |
| `sta-dev-pep` | Azure Storage |

The private endpoints are deployed into:

```text
pe-subnet
```

The connectivity model is:

```text
VNet
 │
 └── pe-subnet
      │
      ├── databricks-dev-pep
      ├── kv-dev-pep
      └── sta-dev-pep
```

---

## Private DNS Zones

The environment uses the following Private DNS Zones:

```text
privatelink.azuredatabricks.net
privatelink.vaultcore.windows.net
privatelink.dfs.core.windows.net
```

They provide private DNS resolution for the associated Azure services.

| Private DNS Zone | Service |
|---|---|
| `privatelink.azuredatabricks.net` | Azure Databricks |
| `privatelink.vaultcore.windows.net` | Azure Key Vault |
| `privatelink.dfs.core.windows.net` | Azure Storage / ADLS Gen2 |

The Private DNS Zones are associated with the appropriate VNet.

---

# Terraform State

Terraform state is stored remotely in Azure Storage.

The Terraform state storage infrastructure is **manually created** and is not managed by the Terraform configuration.

The backend resources are:

```text
Resource Group:
rg-tfworkspace-dev

Storage Account:
stdataingestiondev

Container:
state

State File:
terraform.tfstate
```

The complete state hierarchy is:

```text
rg-tfworkspace-dev
└── stdataingestiondev
    └── state
        └── terraform.tfstate
```

The state storage account must exist before Terraform can initialize the backend.

---

## Terraform Backend

The backend configuration follows the AzureRM backend pattern:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfworkspace-dev"
    storage_account_name = "stdataingestiondev"
    container_name       = "state"
    key                  = "terraform.tfstate"
  }
}
```

The backend infrastructure is intentionally managed outside the main Terraform deployment.

---

# Modules

Terraform modules are stored under:

```text
src/modules/
```

Each resource has its own module.

Example:

```text
src/modules/
├── resource-group/
├── vnet/
├── subnet/
├── nsg/
├── storage-account/
├── key-vault/
├── managed-identity/
├── databricks/
├── databricks-access-connector/
├── private-endpoint/
├── private-dns/
└── ...
```

The actual module names depend on the implementation in the repository.

A typical module structure is:

```text
src/modules/<resource-name>/
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
└── versions.tf
```

Modules should contain reusable Terraform logic.

Environment-specific values should not be hard-coded inside modules.

---

# Varsets

Environment-specific configuration is stored under:

```text
src/varsets/
```

The current environment is:

```text
src/varsets/dev/
```

Each resource has a separate JSON Terraform variable file.

The naming convention is:

```text
<resource-name>_<environment>.auto.tfvars.json
```

For example:

```text
src/varsets/dev/
├── databricks_dev.auto.tfvars.json
├── storage-account_dev.auto.tfvars.json
├── key-vault_dev.auto.tfvars.json
├── vnet_dev.auto.tfvars.json
├── private-endpoint_dev.auto.tfvars.json
└── ...
```

The varsets contain environment-specific values such as:

- Resource names
- Resource group names
- Subnet configuration
- SKU configuration
- Databricks configuration
- Cluster configuration
- Cluster policies
- Private endpoint configuration
- Key Vault configuration
- Storage configuration

---

# Module and Varset Relationship

Each resource follows the same pattern:

```text
                     Resource
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
       Terraform Module          Varset
             │                     │
             │                     │
src/modules/<resource>/    src/varsets/dev/
             │                     │
             └──────────┬──────────┘
                        │
                        ▼
                    Terraform
                        │
                        ▼
                 Azure Resource
```

For example:

```text
Databricks
│
├── Module
│   └── src/modules/databricks/
│
└── Dev Varset
    └── src/varsets/dev/databricks_dev.auto.tfvars.json
```

---

# Configuration Flow

The configuration flows from the varset into Terraform and then into the module.

```text
<resource>_dev.auto.tfvars.json
              │
              ▼
       Terraform Variables
              │
              ▼
          Terraform Module
              │
              ▼
        Azure / Databricks
```

For Databricks:

```text
databricks_dev.auto.tfvars.json
              │
              ▼
       databricks_config
              │
              ▼
       Databricks Module
              │
       ┌──────┼──────────┐
       │      │          │
       ▼      ▼          ▼
   Clusters Policies  Instance Pools
       │      │          │
       └──────┼──────────┘
              ▼
       Azure Databricks
```

---

# Databricks Configuration

Databricks configuration is provided through the `databricks_config` object.

A simplified configuration structure is:

```json
{
  "databricks_config": {
    "databricks_workspace": "dbw-data-platform-dev",
    "databricks_workspace_name": "dbw-data-platform-dev",
    "resource_group_name": "rg-data-platform-dev",
    "policies": [],
    "cluster_config": [],
    "instance_pools": [],
    "scopes": [],
    "groups": [],
    "sql_endpoints": []
  }
}
```

The Databricks module can manage resources such as:

```text
Cluster Policies
Clusters
Instance Pools
Secret Scopes
Secret ACLs
Groups
Permissions
SQL Endpoints
```

---

# Cluster Configuration

Cluster configuration is maintained in the Databricks varset.

Example:

```json
{
  "databricks_config": {
    "cluster_config": [
      {
        "cluster_name": "all-purpose-cluster",
        "node_size": "Standard_D4ds_v5",
        "long_term_support": true,
        "autotermination_minutes": 30,
        "data_security_mode": "USER_ISOLATION",
        "runtime_engine": "PHOTON",
        "policy_name": "all-purpose-cluster-policy",
        "autoscale": {
          "min_value": 2,
          "max_value": 4
        }
      }
    ]
  }
}
```

The cluster configuration supports:

- Node size
- Spark version
- Long-term support runtime
- Auto termination
- Data security mode
- Runtime engine
- Cluster policy
- Autoscaling
- Azure attributes
- Cluster permissions

---

# Cluster Policies

Cluster policies are configured separately from cluster definitions.

The repository can define separate policies for different cluster use cases.

Typical policies include:

```text
all-purpose-cluster-policy
job-cluster-policy
```

Example:

```json
{
  "databricks_config": {
    "policies": [
      {
        "name": "all-purpose-cluster-policy",
        "policy": {
          "cluster_type": {
            "type": "fixed",
            "value": "all-purpose"
          },
          "autotermination_minutes": {
            "type": "range",
            "minValue": 10,
            "maxValue": 120,
            "defaultValue": 30
          }
        }
      },
      {
        "name": "job-cluster-policy",
        "policy": {
          "cluster_type": {
            "type": "fixed",
            "value": "job"
          }
        }
      }
    ]
  }
}
```

A cluster can reference a policy using:

```json
{
  "policy_name": "all-purpose-cluster-policy"
}
```

This keeps cluster configuration and policy configuration separate.

---

# Job and All-Purpose Clusters

The Databricks configuration distinguishes between:

- Job cluster policies
- All-purpose cluster policies
- All-purpose cluster configurations

An all-purpose cluster is created through the Terraform `databricks_cluster` resource.

A job cluster is normally created as part of a Databricks Job and can use a cluster policy.

The conceptual model is:

```text
Cluster Policies
      │
      ├── Job Cluster Policy
      │       │
      │       └── Databricks Job
      │              │
      │              └── Job Cluster
      │
      └── All-Purpose Cluster Policy
              │
              └── All-Purpose Cluster
                      │
                      └── databricks_cluster
```

A job cluster policy can therefore exist without a standalone `databricks_cluster` resource.

---

# Recommended Databricks Varset Structure

The Databricks varset can contain both policies and all-purpose cluster configurations.

Example:

```json
{
  "databricks_config": {
    "databricks_workspace": "dbw-data-platform-dev",
    "databricks_workspace_name": "dbw-data-platform-dev",
    "resource_group_name": "rg-data-platform-dev",

    "policies": [
      {
        "name": "job-cluster-policy",
        "policy": {
          "cluster_type": {
            "type": "fixed",
            "value": "job"
          },
          "spark_version": {
            "type": "regex",
            "pattern": ".*-scala.*"
          },
          "autotermination_minutes": {
            "type": "range",
            "minValue": 10,
            "maxValue": 120,
            "defaultValue": 30
          }
        }
      },
      {
        "name": "all-purpose-cluster-policy",
        "policy": {
          "cluster_type": {
            "type": "fixed",
            "value": "all-purpose"
          },
          "autotermination_minutes": {
            "type": "range",
            "minValue": 10,
            "maxValue": 120,
            "defaultValue": 30
          }
        }
      }
    ],

    "cluster_config": [
      {
        "cluster_name": "all-purpose-cluster",
        "node_size": "Standard_D4ds_v5",
        "long_term_support": true,
        "autotermination_minutes": 30,
        "data_security_mode": "USER_ISOLATION",
        "runtime_engine": "PHOTON",
        "policy_name": "all-purpose-cluster-policy",
        "autoscale": {
          "min_value": 2,
          "max_value": 4
        }
      }
    ]
  }
}
```

The important relationship is:

```text
all-purpose-cluster-policy
            │
            ▼
    all-purpose-cluster
            │
            ▼
    databricks_cluster
```

while:

```text
job-cluster-policy
        │
        ▼
Databricks Job
        │
        ▼
   Job Cluster
```

---

# Environment Separation

The repository currently supports the `dev` environment.

The structure is designed to support additional environments:

```text
src/
└── varsets/
    ├── dev/
    ├── test/
    ├── uat/
    └── prod/
```

For example:

```text
src/varsets/dev/databricks_dev.auto.tfvars.json
src/varsets/test/databricks_test.auto.tfvars.json
src/varsets/uat/databricks_uat.auto.tfvars.json
src/varsets/prod/databricks_prod.auto.tfvars.json
```

The Terraform modules remain shared across environments.

Only environment-specific configuration changes.

---

# Naming Convention

Development Azure resources use the `-dev` naming convention where supported.

Examples:

```text
rg-data-platform-dev
vnet-data-platform-dev
dbw-data-platform-dev
kv-data-platform-dev
ac-data-platform-dev
```

Azure Storage Account names follow Azure naming restrictions:

```text
stlandingareadev
stdataingestiondev
```

Private endpoints use:

```text
databricks-dev-pep
kv-dev-pep
sta-dev-pep
```

Network Security Groups use:

```text
subnet-data-platform-dev-public-nsg
subnet-data-platform-dev-private-nsg
```

---

# Terraform Workflow

The standard Terraform workflow is:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Recommended workflow:

```text
1. Update configuration
        │
        ▼
2. terraform fmt
        │
        ▼
3. terraform validate
        │
        ▼
4. terraform plan
        │
        ▼
5. Review plan
        │
        ▼
6. terraform apply
```

---

## Terraform Initialization

Initialize Terraform:

```bash
terraform init
```

If the backend configuration has changed:

```bash
terraform init -reconfigure
```

The backend storage account and container must already exist.

---

## Terraform Formatting

Format Terraform files:

```bash
terraform fmt -recursive
```

---

## Terraform Validation

Validate the Terraform configuration:

```bash
terraform validate
```

Validation should pass before creating a plan.

---

## Terraform Plan

Create a plan:

```bash
terraform plan
```

Always review the Terraform plan before applying changes.

For CI/CD, a saved plan can be used:

```bash
terraform plan -out=tfplan
```

---

## Terraform Apply

Apply the configuration:

```bash
terraform apply
```

For a previously saved plan:

```bash
terraform apply tfplan
```

---

# Adding a New Resource

To add a new resource, follow these steps.

## 1. Create the Module

Create a new module directory:

```text
src/modules/<resource-name>/
```

Add the required Terraform files:

```text
src/modules/<resource-name>/
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
└── versions.tf
```

---

## 2. Create the Varset

Create the environment-specific varset:

```text
src/varsets/dev/<resource-name>_dev.auto.tfvars.json
```

---

## 3. Add Environment Configuration

Add the environment-specific configuration to the JSON varset.

Do not hard-code development-specific values inside the reusable module.

---

## 4. Reference the Module

Reference the module from the Terraform configuration.

---

## 5. Format

Run:

```bash
terraform fmt -recursive
```

---

## 6. Validate

Run:

```bash
terraform validate
```

---

## 7. Plan

Run:

```bash
terraform plan
```

Review the planned changes.

---

## 8. Apply

After the plan has been reviewed:

```bash
terraform apply
```

---

# Adding a New Environment

To add a new environment, create a new directory under:

```text
src/varsets/
```

For example:

```text
src/varsets/
├── dev/
├── test/
├── uat/
└── prod/
```

Then create the resource-specific varsets.

Example:

```text
src/varsets/test/
├── databricks_test.auto.tfvars.json
├── vnet_test.auto.tfvars.json
├── key-vault_test.auto.tfvars.json
├── storage-account_test.auto.tfvars.json
└── ...
```

The existing Terraform modules under:

```text
src/modules/
```

should be reused.

---

# Security

The platform follows a private-networking and identity-based security model.

Critical services use private connectivity:

```text
Azure Databricks
Azure Key Vault
Azure Storage
```

The environment uses:

- Private Endpoints
- Private DNS Zones
- Network Security Groups
- User-assigned Managed Identity
- Customer-managed keys
- Azure RBAC
- Remote Terraform state

---

## Sensitive Information

Sensitive information must not be committed to the repository.

Do not commit:

```text
Passwords
Client Secrets
Access Keys
SAS Tokens
Private Keys
Certificates containing private material
Terraform State Files
```

Terraform state should remain in the secured Azure Storage backend.

---

# Key Management

Customer-managed keys are stored in:

```text
kv-data-platform-dev
```

Keys:

```text
databrickskey
storageaccountkey
```

The user-assigned managed identity:

```text
keyvault-dev-identity-01
```

provides controlled access to the Key Vault.

The logical access flow is:

```text
Azure Resource
      │
      ▼
Managed Identity
      │
      ▼
Key Vault
      │
      ▼
Customer Managed Key
```

Access should follow the principle of least privilege.

---

# Network Security

The platform is designed around private connectivity.

The high-level connectivity model is:

```text
                     Azure Databricks
                            │
                            ▼
                   vnet-data-platform-dev
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
      Databricks PE     Key Vault PE    Storage PE
             │              │              │
             ▼              ▼              ▼
       Databricks       Key Vault       Storage
                                        │
                                        ▼
                                 stlandingareadev
```

Network access is controlled through:

```text
VNet
Subnets
Network Security Groups
Private Endpoints
Private DNS Zones
Managed Identities
RBAC
```

Public access should only be enabled where explicitly required.

---

# Terraform State Security

Terraform state can contain sensitive infrastructure information.

The state backend is:

```text
rg-tfworkspace-dev
└── stdataingestiondev
    └── state
        └── terraform.tfstate
```

The state storage account should have appropriate:

- Azure RBAC
- Network restrictions
- Encryption
- Access controls
- Auditing
- Backup and recovery

The state infrastructure is manually created and must exist before:

```bash
terraform init
```

---

# Resource Inventory

## Core Azure Resources

| Resource Type | Resource Name |
|---|---|
| Resource Group | `rg-data-platform-dev` |
| Virtual Network | `vnet-data-platform-dev` |
| Storage Account | `stlandingareadev` |
| Key Vault | `kv-data-platform-dev` |
| Managed Identity | `keyvault-dev-identity-01` |
| Databricks Workspace | `dbw-data-platform-dev` |
| Databricks Access Connector | `ac-data-platform-dev` |

## Subnets

| Subnet | Purpose |
|---|---|
| `pe-subnet` | Private endpoints |
| `management-subnet` | Management |
| `subnet-data-platform-dev-public` | Public platform subnet |
| `subnet-data-platform-dev-private` | Private platform subnet |

## Network Security Groups

| NSG | Associated Subnet |
|---|---|
| `subnet-data-platform-dev-public-nsg` | `subnet-data-platform-dev-public` |
| `subnet-data-platform-dev-private-nsg` | `subnet-data-platform-dev-private` |

## Private Endpoints

| Private Endpoint | Target |
|---|---|
| `databricks-dev-pep` | Azure Databricks |
| `kv-dev-pep` | Azure Key Vault |
| `sta-dev-pep` | Azure Storage |

## Private DNS Zones

| DNS Zone | Target |
|---|---|
| `privatelink.azuredatabricks.net` | Azure Databricks |
| `privatelink.vaultcore.windows.net` | Azure Key Vault |
| `privatelink.dfs.core.windows.net` | Azure Storage / ADLS Gen2 |

## Customer Managed Keys

| Key | Purpose |
|---|---|
| `databrickskey` | Databricks CMK |
| `storageaccountkey` | Storage Account CMK |

## Terraform State

| Component | Name |
|---|---|
| Resource Group | `rg-tfworkspace-dev` |
| Storage Account | `stdataingestiondev` |
| Container | `state` |
| State File | `terraform.tfstate` |

---

# Resource Dependency Overview

```text
                         rg-data-platform-dev
                                  │
             ┌────────────────────┼────────────────────┐
             │                    │                    │
             ▼                    ▼                    ▼
           VNet              Key Vault              Storage
             │                    │                    │
             │                    │                    │
             │              Managed Identity           │
             │                    │                    │
             │                    ▼                    │
             │             keyvault-dev-identity-01   │
             │                                         │
             │                                         │
             ├───────────────┐                         │
             │               │                         │
             ▼               ▼                         ▼
       Private Endpoints   Private DNS        Access Connector
             │               │                         │
             │               │                         │
             └───────────────┼─────────────────────────┘
                             │
                             ▼
                    Azure Databricks
                             │
                             ▼
                    dbw-data-platform-dev
```

---

# Design Principles

## Modular Infrastructure

Infrastructure is split into reusable Terraform modules.

Benefits include:

- Reusability
- Separation of concerns
- Easier maintenance
- Easier testing
- Reduced coupling
- Consistent resource deployment

---

## Configuration as Data

Environment-specific values belong in varsets rather than modules.

Avoid hard-coding:

```hcl
resource_group_name = "rg-data-platform-dev"
```

inside a reusable module.

Instead:

```hcl
resource_group_name = var.resource_group_name
```

and provide the value through the appropriate environment varset.

---

## Environment Isolation

Each environment has its own configuration.

```text
dev
test
uat
prod
```

The Terraform modules remain shared across environments.

---

## Security by Default

The platform is designed around:

```text
Private Connectivity
Managed Identities
Customer Managed Keys
Private DNS
Network Security Groups
RBAC
Remote Terraform State
```

Public access should only be enabled where explicitly required.

---

# Recommended Development Process

When making infrastructure changes:

```text
Identify Resource
       │
       ▼
Locate Module
       │
       ▼
Locate Environment Varset
       │
       ▼
Modify Configuration
       │
       ▼
terraform fmt -recursive
       │
       ▼
terraform validate
       │
       ▼
terraform plan
       │
       ▼
Review Plan
       │
       ▼
terraform apply
```

Where possible, make configuration changes in the varset rather than modifying the reusable Terraform module.

---

# Development Environment Summary

| Category | Name |
|---|---|
| Environment | `dev` |
| Resource Group | `rg-data-platform-dev` |
| VNet | `vnet-data-platform-dev` |
| PE Subnet | `pe-subnet` |
| Management Subnet | `management-subnet` |
| Public Subnet | `subnet-data-platform-dev-public` |
| Private Subnet | `subnet-data-platform-dev-private` |
| Public NSG | `subnet-data-platform-dev-public-nsg` |
| Private NSG | `subnet-data-platform-dev-private-nsg` |
| Unity Catalog Storage | `stlandingareadev` |
| Key Vault | `kv-data-platform-dev` |
| Databricks CMK | `databrickskey` |
| Storage CMK | `storageaccountkey` |
| Managed Identity | `keyvault-dev-identity-01` |
| Databricks Workspace | `dbw-data-platform-dev` |
| Access Connector | `ac-data-platform-dev` |
| Databricks PE | `databricks-dev-pep` |
| Key Vault PE | `kv-dev-pep` |
| Storage PE | `sta-dev-pep` |
| Databricks Private DNS | `privatelink.azuredatabricks.net` |
| Key Vault Private DNS | `privatelink.vaultcore.windows.net` |
| Storage Private DNS | `privatelink.dfs.core.windows.net` |
| Terraform State RG | `rg-tfworkspace-dev` |
| Terraform State Storage | `stdataingestiondev` |
| Terraform State Container | `state` |
| Terraform State File | `terraform.tfstate` |

---

# Summary

This repository provides a modular Terraform implementation for the Azure Data Platform and Azure Databricks development environment.

The architecture separates reusable Terraform implementation from environment-specific configuration:

```text
src/
│
├── modules/
│   └── Reusable Terraform Modules
│
└── varsets/
    └── dev/
        └── Environment-specific JSON configuration
```

The platform consists of:

```text
Azure Resource Group
│
├── Virtual Network
│   ├── PE Subnet
│   ├── Management Subnet
│   ├── Public Subnet
│   └── Private Subnet
│
├── Network Security Groups
│
├── Storage Account
│
├── Key Vault
│
├── Managed Identity
│
├── Private Endpoints
│
├── Private DNS Zones
│
├── Databricks Access Connector
│
└── Azure Databricks Workspace
```

Terraform state is maintained remotely using:

```text
rg-tfworkspace-dev
└── stdataingestiondev
    └── state
        └── terraform.tfstate
```

This architecture provides a reusable, environment-aware, modular, and security-focused approach to managing Azure and Databricks infrastructure with Terraform.
````