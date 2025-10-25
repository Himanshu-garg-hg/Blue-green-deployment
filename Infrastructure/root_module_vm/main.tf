
module "new_vm" {
  source              = "../child_module_vm/"
  vm                  = var.new_vm
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  active_env          = var.active_env
}