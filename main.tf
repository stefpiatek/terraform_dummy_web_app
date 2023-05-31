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

resource "azurerm_mssql_database" "sp_dummy_app" {
  name                = random_pet.sqldb_name.id
  server_id         = azurerm_mssql_server.sp_dummy_app.id

  tags = {
    environment = "production"
  }
}



resource "azurerm_service_plan" "sp_dummy_app" {
  name                = "sp_dummy_service_plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "sp_dummy_app" {
  name                = "spdummyapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp_dummy_app.location
  service_plan_id     = azurerm_service_plan.sp_dummy_app.id
  https_only = true

  site_config {
    app_command_line = "python manage.py runserver"
    application_stack {
          python_version = "3.11"
        }
  }
}

resource "azurerm_app_service_source_control" "sp_dummy_app" {
  app_id = azurerm_linux_web_app.sp_dummy_app.id
  repo_url = "https://github.com/stefpiatek/terraform_dummy_web_app"
  branch = "main"
  use_local_git = true
}