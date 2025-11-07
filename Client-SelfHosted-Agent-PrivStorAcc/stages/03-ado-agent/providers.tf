terraform {
  required_version = ">= 1.0"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
  }

  backend "local" {
    path = "terraform-stage3.tfstate"
  }
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/${var.ado_organization}"
}