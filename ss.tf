# Public IP for Load Balancer
resource "azurerm_public_ip" "project-public-ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.projectazure.name
}

# Create Load Balancer Front-End
resource "azurerm_lb" "project-lb" {
  name                = "lb"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  frontend_ip_configuration {
    name                 = "internal"
    public_ip_address_id = azurerm_public_ip.project-public-ip.id
  }
}

# Create Load Balancer Back-End Address Pool
resource "azurerm_lb_backend_address_pool" "bpepool" {
  name                = "backend-pool"
  loadbalancer_id     = azurerm_lb.project-lb.id
}

# Create Load Balancer Probe HTTP
resource "azurerm_lb_probe" "http" {
  name                = "lb-probe-http"
  loadbalancer_id     = azurerm_lb.project-lb.id
  port                = 80
  protocol            = "Http"
  request_path        = "/index.html"
  number_of_probes    = 3
  interval_in_seconds = 5
}

# Create Load Balancer  Probe  SSH
resource "azurerm_lb_probe" "ssh" {
  name                = "lb-probe-ssh"
  loadbalancer_id     = azurerm_lb.project-lb.id
  port                = 22
}

# Create Load Balancer Rule HTTP
resource "azurerm_lb_rule" "lbrule-http" {
  name                           = "lb-rule-http"
  loadbalancer_id                = azurerm_lb.project-lb.id
  probe_id                       = azurerm_lb_probe.http.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
}

# Create Load Balancer  Rule  SSH
resource "azurerm_lb_rule" "ssh" {
  name                           = "lb-rule-ssh"
  loadbalancer_id                = azurerm_lb.project-lb.id
  probe_id                       = azurerm_lb_probe.ssh.id
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  
}

# Traffic Manager Profile for Load Balancing
resource "azurerm_traffic_manager_profile" "traffic_profile8250" {
  name                   = "traffic-profile8250"
  resource_group_name    = azurerm_resource_group.projectazure.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "traffic-profile8250"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

# End-Point for Traffic Manager
resource "azurerm_traffic_manager_azure_endpoint" "endpoint" {
  name               = "endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic_profile8250.id
  weight             = 100
  target_resource_id = azurerm_public_ip.project-public-ip.id
}

#######################################################################################

# Create Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "project-vmss" {
  name                            = "vmss"
  resource_group_name             = azurerm_resource_group.projectazure.name
  location                        = azurerm_resource_group.projectazure.location
  sku                             = "Standard_D2S_v3"
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
    network_security_group_id = azurerm_network_security_group.project-nsg.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet3.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 21
    max_unhealthy_instance_percent          = 22
    max_unhealthy_upgraded_instance_percent = 23
    pause_time_between_batches              = "PT30S"
  }

  depends_on = [azurerm_lb_rule.lbrule-http]
}