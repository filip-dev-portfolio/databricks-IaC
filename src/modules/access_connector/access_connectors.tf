resource "azapi_resource" "access_connector" {
    for_each = local.access_connectors
    type     = "Microsoft.Databricks/workspaces/accessConnectors@2023-04-01"
    name     = each.value.access_connector_name
    location = data.azurerm_resource_group.rg[each.value.access_connector_name].location
    parent_id = data.azurerm_resource_group.rg[each.value.access_connector_name].id
    identity {
        type = "SystemAssigned"
    }
}