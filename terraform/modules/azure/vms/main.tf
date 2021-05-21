resource "azurerm_public_ip" "vm-pip" {
  count = var.createPublicIp ? var.numInstances : 0

  name                = "${var.namePrefix}${count.index}-pip"
  location            = var.location
  resource_group_name = var.resourceGroup
  allocation_method   = "Dynamic"
  sku                 = "basic"
}

resource "azurerm_network_interface" "vm-nic" {
  count = var.numInstances

  name                = "${var.namePrefix}${count.index}-nic"
  location            = var.location
  resource_group_name = var.resourceGroup

  ip_configuration {
    name                          = "${var.namePrefix}${count.index}-ipconfig"
    subnet_id                     = var.subnetId
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = var.createPublicIp ? azurerm_public_ip.vm-pip[count.index].id : null
  }
}

resource "azurerm_virtual_machine" "ubuntu-server" {
  count = var.os == "ubuntu-server" ? var.numInstances : 0

  name                  = "${var.namePrefix}${count.index}"
  vm_size               = var.size
  network_interface_ids = [azurerm_network_interface.vm-nic[count.index].id]
  location              = var.location
  resource_group_name   = var.resourceGroup

  storage_os_disk {
    name              = "${var.namePrefix}${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.namePrefix}${count.index}"
    admin_username = var.credentials.username
    admin_password = var.credentials.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "windows" {
  count = var.os == "windows" ? var.numInstances : 0

  name                  = "${var.namePrefix}${count.index}"
  vm_size               = var.size
  network_interface_ids = [azurerm_network_interface.vm-nic[count.index].id]
  location              = var.location
  resource_group_name   = var.resourceGroup

  storage_os_disk {
    name              = "${var.namePrefix}${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.namePrefix}${count.index}"
    admin_username = var.credentials.username
    admin_password = var.credentials.password
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}
