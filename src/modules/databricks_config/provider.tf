terraform {
    
  required_providers {
    databricks = {
      source  = "databricks/databricks"

    }
  }
}

provider "databricks" {
    host  = var.databricks_config.databricks_host
}