variable "new_vm" {
  type = map(object({
    vnet_address_space           = list(string)
    admin_username               = string
    admin_password               = string
    vm_size                      = string
    os_disk_caching              = string
    os_disk_storage_account_type = string
    source_image_publisher       = string
    source_image_offer           = string
    source_image_sku             = string
    source_image_version         = string
    subnet = list(object({
      subnet_name             = string
      subnet_address_prefixes = list(string)
    }))
  }))
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string

}

variable "location" {
  type = string

}

variable "active_env" {
  type    = string
  default = "blue"
}