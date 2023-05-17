output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "sqlserver_name" {
  value = azurerm_mssql_server.sp_dummy_app.name
}

output "sqldb_name" {
  value = azurerm_sql_database.sp_dummy_app.name
}