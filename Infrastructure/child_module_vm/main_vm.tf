resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = var.vm["frontend-blue"].vnet_address_space

  dynamic "subnet" {
    for_each = var.vm["frontend-blue"].subnet
    content {
      name             = subnet.value.subnet_name
      address_prefixes = subnet.value.subnet_address_prefixes
    }
  }
}

resource "azurerm_network_interface" "nic1" {
  for_each            = var.vm
  name                = "nic-${each.key}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = azurerm_virtual_network.vnet1.subnet.*.id[index(azurerm_virtual_network.vnet1.subnet.*.name, "vm-subnet")]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = can(regex("^frontend", each.key)) ? azurerm_public_ip.pip1[each.key].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  for_each                        = var.vm
  name                            = "linux-vm-${each.key}"
  location                        = azurerm_resource_group.rg1.location
  resource_group_name             = azurerm_resource_group.rg1.name
  network_interface_ids           = [azurerm_network_interface.nic1[each.key].id]
  size                            = each.value.vm_size
  disable_password_authentication = each.value.admin_password == "" ? true : false
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  os_disk {
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }
  source_image_reference {
    publisher = each.value.source_image_publisher
    offer     = each.value.source_image_offer
    sku       = each.value.source_image_sku
    version   = each.value.source_image_version
  }
}


locals {
  frontend_vms = {
    for k, v in var.vm : k => v
    if can(regex("^frontend", k))
  }
}

resource "azurerm_public_ip" "pip1" {
  for_each            = local.frontend_vms
  name                = "pip-${each.key}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pipappgw" {
  name                = "pip-appgw"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
}

locals {
  backend_address_pool_name      = "beap"
  frontend_port_name             = "feport"
  frontend_ip_configuration_name = "feip"
  http_setting_name              = "be-htst"
  listener_name                  = "httplstn"
  request_routing_rule_name      = "rqrt"
  redirect_configuration_name    = "rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "appgateway"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_virtual_network.vnet1.subnet.*.id[index(azurerm_virtual_network.vnet1.subnet.*.name, "appgw-subnet")]
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pipappgw.id
  }

  backend_address_pool {
    name = "backendpool-blue"
    # If you want to use NIC private IPs:
    ip_addresses = [
      azurerm_network_interface.nic1["frontend-blue"].ip_configuration[0].private_ip_address
    ]
  }

  backend_address_pool {
    name = "backendpool-green"
    # If you want to use NIC private IPs:
    ip_addresses = [
      azurerm_network_interface.nic1["frontend-green"].ip_configuration[0].private_ip_address
    ]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = var.active_env == "blue" ? "backendpool-blue" : "backendpool-green"
    backend_http_settings_name = local.http_setting_name
  }
}


resource "azurerm_mssql_server" "server" {
  name                         = "newtodosqlserver"
  location                     = azurerm_resource_group.rg1.location
  resource_group_name          = azurerm_resource_group.rg1.name
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password@123"
}

resource "azurerm_mssql_database" "database" {
  name         = "db"
  server_id    = azurerm_mssql_server.server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"
}

