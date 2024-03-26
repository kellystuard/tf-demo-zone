terraform {
  required_version = "~>1.5"
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.10.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.53"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.97"
    }
  }
}

provider "spacelift" {}

provider "tfe" {}

provider "azurerm" {
  features {}
}
