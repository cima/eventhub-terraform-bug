terraform {
  backend "azurerm" {}
}
provider "azurerm" {}

# Directly taken from https://www.terraform.io/docs/providers/azurerm/r/eventhub_namespace.html
resource "azurerm_resource_group" "eventhub_terraform_bug" {
  name     = "eventhub-terraform-bug"
  location = "west europe"
}
resource "azurerm_eventhub_namespace" "eventhub_terraform_bug_namespace" {
  name                = "eventhub-terraform-bug"
  location            = "${azurerm_resource_group.eventhub_terraform_bug.location}"
  resource_group_name = "${azurerm_resource_group.eventhub_terraform_bug.name}"
  sku                 = "Standard"
}