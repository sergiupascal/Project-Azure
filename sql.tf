resource "random_string" "random" {
  length           = 14
  special          = false
  override_special = "/@£$"
  upper            = false
}


resource "azurerm_mysql_server" "projectwordpress" {
  name                = "projectwordpress-${random_string.random.result}"
  location            = azurerm_resource_group.projectazure.location
  resource_group_name = azurerm_resource_group.projectazure.name

  administrator_login          = "mysqladmin"
  administrator_login_password = "H@ShiCORP!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}