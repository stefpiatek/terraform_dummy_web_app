variable "resource_location" {
  default     = "uksouth"
  description = "Location of the resources."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of a resource with a random ID so name is unique in your Azure subscription."
}

variable "storage_name_prefix" {
  default     = "st"
  description = "Prefix of a resource with a random ID so name is unique in your Azure subscription."
}

variable "sql_server_name_prefix" {
  default     = "sql"
  description = "Prefix of a resource with a random ID so name is unique in your Azure subscription."
}

variable "sql_db_name_prefix" {
  default     = "sqldb"
  description = "Prefix of a resource with a random ID so name is unique in your Azure subscription."
}

# can set on running of command or use env variable TF_VAR_{variable_name}
variable "sql_username" {
  description = "Admin username for sql server"
  type = string
  sensitive = true
}

variable "sql_password" {
  description = "Admin password for sql server"
  type = string
  sensitive = true
}