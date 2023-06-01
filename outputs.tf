output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "sqlserver_fqdn" {
  value = azurerm_mssql_server.sp_dummy_app.fully_qualified_domain_name
}

output "sqldb_name" {
  value = azurerm_mssql_database.sp_dummy_app.name
}

output "developer_ip" {
  value = data.http.local_ip[0].response_body
}

output "web_app_url" {
  value = azurerm_linux_web_app.sp_dummy_app.default_hostname
}
