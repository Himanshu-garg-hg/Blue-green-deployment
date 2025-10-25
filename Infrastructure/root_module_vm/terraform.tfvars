location            = "Central India"
resource_group_name = "rg-todoapp"
vnet_name           = "vnet-todoapp"
active_env          = "green"

new_vm = {
  frontend-blue = {
    vnet_name                    = "vnet-todoapp"
    vnet_address_space           = ["10.0.0.0/16"]
    admin_username               = "azureuser"
    admin_password               = "Password1234!"
    vm_size                      = "Standard_B1s"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    source_image_publisher       = "Canonical"
    source_image_offer           = "UbuntuServer"
    source_image_sku             = "18.04-LTS"
    source_image_version         = "latest"
    subnet = [
      {
        subnet_name             = "vm-subnet"
        subnet_address_prefixes = ["10.0.0.0/28"]
      },
      {
        subnet_name             = "appgw-subnet"
        subnet_address_prefixes = ["10.0.0.16/28"]
      }
    ]
  },
  frontend-green = {
    vnet_name                    = "vnet-todoapp"
    vnet_address_space           = ["10.0.0.0/16"]
    admin_username               = "azureuser"
    admin_password               = "Password1234!"
    vm_size                      = "Standard_B1s"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    source_image_publisher       = "Canonical"
    source_image_offer           = "UbuntuServer"
    source_image_sku             = "18.04-LTS"
    source_image_version         = "latest"
    subnet = [
      {
        subnet_name             = "vm-subnet"
        subnet_address_prefixes = ["10.0.0.0/28"]
      },
      {
        subnet_name             = "appgw-subnet"
        subnet_address_prefixes = ["10.0.0.16/28"]
      }
    ]
  },
  backend-blue = {
    vnet_name                    = "vnet-todoapp"
    vnet_address_space           = ["10.0.0.0/16"]
    admin_username               = "azureuser"
    admin_password               = "Password1234!"
    vm_size                      = "Standard_B1s"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    source_image_publisher       = "Canonical"
    source_image_offer           = "UbuntuServer"
    source_image_sku             = "18.04-LTS"
    source_image_version         = "latest"
    subnet = [
      {
        subnet_name             = "vm-subnet"
        subnet_address_prefixes = ["10.0.0.0/28"]
      },
      {
        subnet_name             = "appgw-subnet"
        subnet_address_prefixes = ["10.0.0.16/28"]
      }
    ]
  },
  backend-green = {
    vnet_address_space           = ["10.0.0.0/16"]
    admin_username               = "azureuser"
    admin_password               = "Password1234!"
    vm_size                      = "Standard_B1s"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    source_image_publisher       = "Canonical"
    source_image_offer           = "UbuntuServer"
    source_image_sku             = "18.04-LTS"
    source_image_version         = "latest"
    subnet = [
      {
        subnet_name             = "vm-subnet"
        subnet_address_prefixes = ["10.0.0.0/28"]
      },
      {
        subnet_name             = "appgw-subnet"
        subnet_address_prefixes = ["10.0.0.16/28"]
      }
    ]
  }
}