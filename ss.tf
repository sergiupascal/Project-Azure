resource "azurerm_public_ip" "project-public-ip" {
  name                = "publicip"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "project-lb" {
  name                = "lb"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  frontend_ip_configuration {
    name                 = "internal"
    public_ip_address_id = azurerm_public_ip.project-public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  name                = "backend-pool"
  loadbalancer_id     = azurerm_lb.project-lb.id
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  name                           = "nat-pool"
  resource_group_name            = azurerm_resource_group.projectazure.name
  loadbalancer_id                = azurerm_lb.project-lb.id
  frontend_ip_configuration_name = "internal"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 90
  backend_port                   = 8080
}

resource "azurerm_lb_probe" "lbprobe" {
  name                = "lb-probe"
  loadbalancer_id     = azurerm_lb.project-lb.id
  port                = 22
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "lb-rule"
  resource_group_name            = azurerm_resource_group.projectazure.name
  loadbalancer_id                = azurerm_lb.project-lb.id
  probe_id                       = azurerm_lb_probe.lbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "internal"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
}

resource "azurerm_linux_virtual_machine_scale_set" "project-vmss" {
  name                            = "vmss"
  resource_group_name             = azurerm_resource_group.projectazure.name
  location                        = azurerm_resource_group.projectazure.location
  sku                             = "Standard_F2"
  instances                       = 2
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  health_probe_id                 = azurerm_lb_probe.lbprobe.id
  upgrade_mode                    = "Rolling"

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
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 21
    max_unhealthy_instance_percent          = 22
    max_unhealthy_upgraded_instance_percent = 23
    pause_time_between_batches              = "PT30S"
  }

  depends_on = [azurerm_lb_rule.lbrule]
}