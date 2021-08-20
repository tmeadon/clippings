resource "azurerm_network_interface" "vm_nic" {
  resource_group_name = var.resource_group_name
  name                = "${var.vm_details.name}-nic"
  location            = var.vm_details.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.vm_details.subnet_id
    public_ip_address_id          = var.vm_details.pip_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  resource_group_name   = var.resource_group_name
  name                  = var.vm_details.name
  location              = var.vm_details.location
  size                  = "Standard_DS1_v2"
  admin_username        = "tom"
  admin_password        = var.vm_details.admin_password
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "None"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "vm_data_disk" {
  resource_group_name  = var.resource_group_name
  name                 = "${var.vm_details.name}-disk1"
  location             = var.vm_details.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.vm_data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "vm_dsc" {
  name                       = "dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.PowerShell"
  type                       = "DSC"
  type_handler_version       = "2.80"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "modulesUrl": "${var.vm_details.dsc_url}",
      "sasToken": "${var.vm_details.dsc_sas_token}",
      "configurationFunction": "dsc.ps1\\config"
    }
  SETTINGS

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.vm_data_disk_attachment
  ]
}
