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

# Create a network security group
resource "azurerm_network_security_group" "project" {
  name                = "project-nsg"
  location            = azurerm_resource_group.ProjectAzure.location
  resource_group_name = azurerm_resource_group.ProjectAzure.name
}

# Allow inbound SSH (port 22) traffic
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.ProjectAzure.name
  network_security_group_name = azurerm_network_security_group.project.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Allow inbound MySQL (port 3306) traffic
resource "azurerm_network_security_rule" "allow_mysql" {
  name                        = "allow-mysql"
  priority                    = 1002
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.ProjectAzure.name
  network_security_group_name = azurerm_network_security_group.project.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Allow inbound HTTPS (port 443) traffic
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow-https"
  priority                    = 1003
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.ProjectAzure.name
  network_security_group_name = azurerm_network_security_group.project.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


# Create subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.1.0/24"]
  security_group = azurerm_network_security_group.project.id
}

# Create subnet2
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.2.0/24"]
  security_group = azurerm_network_security_group.project.id
}

# Create subnet3
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.ProjectAzure.name
  virtual_network_name = azurerm_virtual_network.ProjectAzure.name
  address_prefixes     = ["10.0.3.0/24"]
  security_group = azurerm_network_security_group.project.id
}