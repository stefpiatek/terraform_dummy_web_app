resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_location
  name     = random_pet.rg_name.id
}

resource "random_pet" "storage_name" {
  prefix = var.storage_name_prefix
  separator = ""
}

resource "azurerm_storage_account" "sp_dummy_app" {
  name                     = random_pet.storage_name.id
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "random_pet" "sql_name" {
  prefix = var.sql_server_name_prefix
}

resource "azurerm_mssql_server" "sp_dummy_app" {
  name                         = random_pet.sql_name.id
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_username
  administrator_login_password = var.sql_password
  minimum_tls_version          = "1.2"

  tags = {
    environment = "production"
  }
}

resource "random_pet" "sqldb_name" {
  prefix = var.sql_server_name_prefix
}

resource "azurerm_sql_database" "sp_dummy_app" {
  name                = random_pet.sqldb_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_mssql_server.sp_dummy_app.name

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_firewall_rule" "sp_dummy_app" {
  name             = "Allow local dev for stef"
  server_id        = azurerm_mssql_server.sp_dummy_app.id
  start_ip_address = data.http.local_ip[0].response_body
  end_ip_address   = data.http.local_ip[0].response_body
}
