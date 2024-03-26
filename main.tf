data "azurerm_resource_group" "zone" {
  name     = var.zone_resource_group_name
}

resource "null_resource" "test" {
}
