variable "resource_group_name" {
  type = string
}

variable "vm_details" {
  type = object(
    {
      name           = string
      location       = string
      subnet_id      = string
      pip_id         = string
      dsc_url        = string
      dsc_sas_token  = string
      admin_password = string
    }
  )
}
