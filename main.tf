resource "azurerm_resource_group" "zone" {
  name     = "test"
  location = var.zone_resource_group_location
}

resource "null_resource" "test" {
}
