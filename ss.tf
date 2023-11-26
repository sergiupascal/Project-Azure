resource "azurerm_public_ip" "project-ip" {
  name                = "test"
  location            = azurerm_resource_group.ProjectAzure.location
  resource_group_name = azurerm_resource_group.ProjectAzure.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.ProjectAzure.name

  tags = {}
}

resource "azurerm_lb" "project-lb" {
  name                = "test"
  location            = azurerm_resource_group.ProjectAzure.location
  resource_group_name = azurerm_resource_group.ProjectAzure.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.project-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.project-lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.ProjectAzure.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.project-lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.project-lb.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/health"
  port            = 8080
}

resource "azurerm_linux_virtual_machine_scale_set" "Project" {
  name                = "Project-vmss"
  resource_group_name = azurerm_resource_group.ProjectAzure.name
  location            = azurerm_resource_group.ProjectAzure.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  custom_data                     = filebase64("userdata.sh")
  health_probe_id                 = azurerm_lb_probe.http.id
  disable_password_authentication = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = [ 
        azurerm_subnet.subnet1.id,
        azurerm_subnet.subnet2.id,
        azurerm_subnet.subnet3.id
      ]
    }
  }
}

