# Create a resource group
resource "azurerm_resource_group" "ProjectAzure" {
  name     = "ProjectAzure-resources"
  location = "westus"
}


# Create a virtual network within the resource group
resource "azurerm_virtual_network" "ProjectAzure" {
  name                = "ProjectAzure-network"
  resource_group_name = azurerm_resource_group.ProjectAzure.name
  location            = azurerm_resource_group.ProjectAzure.location
  address_space       = ["10.0.0.0/16"]
}


# Create subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet2
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create subnet3
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.3.0/24"]
}