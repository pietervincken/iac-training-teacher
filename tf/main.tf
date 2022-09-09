# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.22.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.28.1"
    }
  }
  backend "azurerm" {
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}

locals {

  name="jworksyppiac"

  common_tags = {
    created-by = "pieter.vincken@ordina.be"
    project    = local.name
  }
  location = "West Europe"

  trainees=tomap({
    "pieter": "Pieter.Vincken@ordina.be",
    "maarten": "maarten.casteels@ordina.be",
    # "pieterjan": "Pieter-Jan.Lavaerts@ordina.be",
    # "yanko": "Yanko.Buyens@ordina.be",
    # "femke": "Femke.Tack@ordina.be",
    # "lander": "Lander.Marien@ordina.be",
    # "eli": "Eli.Kakiashvili@ordina.be",
    # "ferre": "Ferre.Vangenechten@ordina.be",
    # "ali": "Ali.Alwasseti@ordina.be",
    # "robbe": "Robbe.DeProft@ordina.be"
  })
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${local.name}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.name
  kubernetes_version  = "1.24.3"

  default_node_pool {
    zones               = [3]
    node_count          = 3
    enable_auto_scaling = false
    vm_size             = "standard_b2s"
    name                = "default"
    os_sku              = "Ubuntu"
  }

 azure_active_directory_role_based_access_control {
    managed = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "heavy" {
  name                  = "heavy"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  vm_size               = "standard_b2ms"
  node_count            = 1
}

module "ypps" {
  source      = "./modules/ypp"
  for_each    = local.trainees
  name        = "${local.name}${each.key}"
  common_tags = local.common_tags
  location    = azurerm_resource_group.rg.location
  email       = each.value
  aks_id      = azurerm_kubernetes_cluster.cluster.id
}
