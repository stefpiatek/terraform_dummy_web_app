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
  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    http_logs {
        file_system {
          retention_in_days = 10
          retention_in_mb   = 25
        }
      }
  }
  site_config {
    application_stack {
          docker_image = "docker.io/stefpiatek/sp_dummy_app"
          docker_image_tag = "latest"
        }
  }
  app_settings = {
    "DJANGO_SECRET_KEY" = var.django_secret,
    "DB_NAME" = azurerm_mssql_server.sp_dummy_app.name,
    "DB_USER" = azurerm_mssql_server.sp_dummy_app.administrator_login,
    "DB_PASSWORD" = azurerm_mssql_server.sp_dummy_app.administrator_login_password,
    "DB_HOST" = azurerm_mssql_server.sp_dummy_app.fully_qualified_domain_name,
  }
}

# was complaining here that there was no github token even when using local git, but wonder if there was some stale state?
resource "azurerm_source_control_token" "sp_dummy_app" {
  type  = "GitHub"
  token = var.gh_token
}

# Allow access to the webapp
resource "azurerm_network_security_group" "sp_dummy_app" {
  name                = "example-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
