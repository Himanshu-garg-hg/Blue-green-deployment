terraform {
  backend "azurerm" {
    storage_account_name = "donotdeletestorage"
    resource_group_name = "donotdelete"
    container_name = "donotdeletecontainer"
    key = "donotdelte.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.49.0"
    }
  }
  
}

provider "azurerm" {
  features {}
  subscription_id = "651a708a-a61f-48a6-8006-0d3a0036a680"

}