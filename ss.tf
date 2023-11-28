resource "azurerm_public_ip" "project-public-ip" {
  name                = "public-ip"
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

resource "azurerm_lb_probe" "http" {
  name                = "lb-probe"
  loadbalancer_id     = azurerm_lb.project-lb.id
  port                = 80
  protocol            = "Http"
  request_path        = "/index.html"
  number_of_probes    = 3
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.project-lb.id
  probe_id                       = azurerm_lb_probe.http.id
  frontend_ip_configuration_name = "internal"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
}

resource "azurerm_linux_virtual_machine_scale_set" "project-vmss" {
  name                            = "vmss"
  resource_group_name             = azurerm_resource_group.projectazure.name
  location                        = azurerm_resource_group.projectazure.location
  sku                             = "Standard_D25_v3"
  instances                       = 2
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  custom_data                     = filebase64("userdata.sh")
  health_probe_id                 = azurerm_lb_probe.http.id
  upgrade_mode                    = "Rolling"

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
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