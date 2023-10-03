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

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}

locals {

  name   = "jworksyppiac"
  domain = "jworks.pietervincken.com"

  common_tags = {
    created-by = "pieter.vincken@ordina.be"
    project    = local.name
  }
  location = "West Europe"

  trainees = tomap({
    "pieter" : "Pieter.Vincken@ordina.be",
    "tim" : "tim.vandendriessche@ordina.be",
    "viktor" : "viktor.vansteenweghen@ordina.be",
    "omer" : "omer.tulumen@ordina.be",
    "oumaima" : "oumaima.zerouali@ordina.be",
    "gabriel" : "gabriel.delapena@ordina.be",
  })
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags     = local.common_tags
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${local.name}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.name
  kubernetes_version  = "1.27.3"

  default_node_pool {
    zones               = [3]
    node_count          = 3
    enable_auto_scaling = false
    vm_size             = "standard_b2ms"
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

## Id is needed for scope of role assignment.
data "azurerm_resource_group" "k8s_node_rg" {
  name = azurerm_kubernetes_cluster.cluster.node_resource_group
}

# Needed for aad-pod-identity
# Contributor role on VMSS
resource "azurerm_role_assignment" "aad_pod_identity_VMC" {
  scope                = data.azurerm_resource_group.k8s_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

# Needed for aad-pod-identity
# Managed Identity Operator role on resource group holding the actual identities
resource "azurerm_role_assignment" "aad_pod_identity_MIO" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

# DNS Zone for this project
resource "azurerm_dns_zone" "domain" {
  name                = local.domain
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "external_dns_operator" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "external-dns-operator"
}

# External DNS operator permissions on dns zone
resource "azurerm_role_assignment" "external_dns_operator" {
  scope                = azurerm_dns_zone.domain.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.external_dns_operator.principal_id
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
