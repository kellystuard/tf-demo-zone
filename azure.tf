# automatically create the appropriately-named resource group in Azure
resource "azurerm_resource_group" "applications" {
  for_each = local.application_environments

  name     = "${var.resource_prefix}${each.key}"
  location = data.azurerm_resource_group.zone.location
  #location = local.hubs[each.value.env] each.value.azure_location

  tags = {
    application = each.value.app
    cost_center = each.value.cost_center
    description = each.value.name
    environment = each.value.env
  }
}