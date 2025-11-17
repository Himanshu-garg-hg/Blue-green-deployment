terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.47.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "651a708a-a61f-48a6-8006-0d3a0036a680"

}