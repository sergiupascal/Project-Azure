resource "azurerm_public_ip" "project-public-ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.projectazure.name

  tags = {}
}

resource "azurerm_lb" "project-lb" {
  name                = "project-lb"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.project-public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.project-lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.projectazure.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.project-lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "lbprobe" {
  loadbalancer_id = azurerm_lb.project-lb.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/health"
  port            = 8080
}

resource "azurerm_linux_virtual_machine_scale_set" "project-vmss" {
  name                = "project-vmss"
  resource_group_name = azurerm_resource_group.projectazure.name
  location            = azurerm_resource_group.projectazure.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "adminuser"
  admin_password      = "pa$$w0rd"
  custom_data         = filebase64("userdata.sh")
  health_probe_id                 = azurerm_lb_probe.lbprobe.id
  disable_password_authentication = false

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true
    network_security_group_id = azurerm_network_security_group.project-nsg.id

    ip_configuration {
      name      = "internal1"
      primary   = true
      subnet_id = azurerm_subnet.subnet1.id
    }
    ip_configuration {
        name      = "internal2"
        primary   = true
        subnet_id = azurerm_subnet.subnet2.id
    }
    ip_configuration {
      name      = "internal3"
      primary   = true
      subnet_id = azurerm_subnet.subnet3.id
    }
  }
}

