terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" 
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "state-file-tf"
    storage_account_name = "statefileazlukas"  #The one you made in the GUI
    container_name       = "tf-state"
    key                  = "prod.terraform.tf-state"
    use_azuread_auth     = true  #Tells Terraform to use your login/identity
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}