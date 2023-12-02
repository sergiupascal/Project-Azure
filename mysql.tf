resource "random_string" "random" {
  length           = 14
  special          = false
  override_special = "/@£$"
  upper            = false
}

# MYSQL Server
resource "azurerm_mysql_server" "projectwordpress" {
  name                = "projectwordpress-${random_string.random.result}"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  administrator_login          = "adminuser"
  administrator_login_password = "H@ShiCORP!"

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
}

# MYSQL Database
resource "azurerm_mysql_database" "project-db-wordpress" {
  name                = "project-db"
  resource_group_name = azurerm_resource_group.projectazure.name
  server_name         = azurerm_mysql_server.projectwordpress.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# MySQL Firewall - Access to AWS Route 53
resource "azurerm_mysql_firewall_rule" "azure" {
  name                = "public-internet"
  resource_group_name = azurerm_resource_group.projectazure.name
  server_name         = azurerm_mysql_server.projectwordpress.name
  start_ip_address    = azurerm_public_ip.project-public-ip.ip_address
  end_ip_address      = azurerm_public_ip.project-public-ip.ip_address
}

# MySQL Firewall - Access to Azure Resources
resource "azurerm_mysql_firewall_rule" "wordpress" {
  name                = "mysql-firewall-rule"
  resource_group_name = azurerm_resource_group.projectazure.name
  server_name         = azurerm_mysql_server.projectwordpress.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}