variable "base_name" {
  type = string
}

variable "regions" {
  type = object(
    {
      primary   = string
      secondary = string
    }
  )
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}
