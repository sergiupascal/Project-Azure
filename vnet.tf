# Create a resource group
resource "azurerm_resource_group" "projectazure" {
  name     = "projectazure-resources"
  location = var.location
}


# Create a virtual network within the resource group
resource "azurerm_virtual_network" "projectazure-vnet" {
  name                = "projectazure-network"
  resource_group_name = azurerm_resource_group.projectazure.name
  location            = azurerm_resource_group.projectazure.location
  address_space       = ["10.0.0.0/16"]
}

# Create subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.projectazure.name
  virtual_network_name = azurerm_virtual_network.projectazure-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet2 for Internet Gateway
resource "azurerm_subnet" "subnet2" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.projectazure.name
  virtual_network_name = azurerm_virtual_network.projectazure-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create subnet3
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.projectazure.name
  virtual_network_name = azurerm_virtual_network.projectazure-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create Virtual Network Interface
resource "azurerm_network_interface" "project-nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a network security group
resource "azurerm_network_security_group" "project-nsg" {
  name                = "project-nsg"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
}

# Allow inbound SSH (port 22) traffic
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.projectazure.name
  network_security_group_name = azurerm_network_security_group.project-nsg.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Allow inbound HTTP (port 80) traffic
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http"
  priority                    = 1004
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.projectazure.name
  network_security_group_name = azurerm_network_security_group.project-nsg.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Allow inbound MySQL (port 3306) traffic
resource "azurerm_network_security_rule" "allow_mysql" {
  name                        = "allow-mysql"
  priority                    = 1002
  direction                   = "Inbound"
  resource_group_name         = azurerm_resource_group.projectazure.name
  network_security_group_name = azurerm_network_security_group.project-nsg.name
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
  resource_group_name         = azurerm_resource_group.projectazure.name
  network_security_group_name = azurerm_network_security_group.project-nsg.name
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Network Security Group & Subnet #3 Association
resource "azurerm_subnet_network_security_group_association" "project-nsg-sub" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.project-nsg.id
}

# Public IP for Internet Gateway
resource "azurerm_public_ip" "project-igw-ip" {
  name                = "IGW-IP"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
  allocation_method   = "Dynamic"
}

# Internet Gateway
resource "azurerm_virtual_network_gateway" "project-igw" {
  name                = "IGW"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
  type     = "Vpn"
  vpn_type = "RouteBased"
  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.project-igw-ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet2.id
  }
}