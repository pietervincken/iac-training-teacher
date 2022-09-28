# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.22.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-jworksyppiacpieter"
    storage_account_name = "sajworksyppiacpieter"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "rg-jworksyppiacpieter"
  location            = "West Europe"
  name                = "yppiacpieter"
}

resource "azurerm_key_vault" "mykeyvault" {
  name                = "kv${local.name}"
  resource_group_name = local.resource_group_name
  sku_name            = "standard"
  tenant_id           = "cbed0302-0bb5-413f-bba6-4b50f09b5470"
  location            = local.location
}

resource "azurerm_key_vault_access_policy" "myaccess" {
  key_vault_id = azurerm_key_vault.mykeyvault.id
  tenant_id    = azurerm_key_vault.mykeyvault.tenant_id
  object_id    = "923969b3-156f-415e-8e3f-301bb394f5f4"
  secret_permissions = [
    "Delete", "Get", "List", "Set", "Purge"
  ]
}

resource "azurerm_key_vault_secret" "mysecret" {
  name         = "mysecret"
  key_vault_id = azurerm_key_vault.mykeyvault.id
  value        = "hello-world"

  depends_on = [
    azurerm_key_vault_access_policy.myaccess
  ]
}

resource "azurerm_container_group" "aci-test" {
  name                = "aci-${local.name}"
  location            = local.location
  resource_group_name = local.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = local.name
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "bitnami/phppgadmin"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "DATABASE_ENABLE_EXTRA_LOGIN_SECURITY" = "yes"
      "DATABASE_HOST"                        = azurerm_postgresql_server.database.fqdn
      "DATABASE_SSL_MODE"                    = "require"
      "PHPPGADMIN_URL_PREFIX"                = "yppiac"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "azurerm_key_vault_secret" "pgadmin" {
  key_vault_id = azurerm_key_vault.mykeyvault.id
  name         = "pgadmin"
  value        = random_password.password.result
  depends_on = [
    azurerm_key_vault_access_policy.myaccess
  ]
}

resource "azurerm_postgresql_server" "database" {
  name                = "pgs-${local.name}"
  location            = local.location
  resource_group_name = local.resource_group_name

  administrator_login          = local.name
  administrator_login_password = random_password.password.result

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}

resource "azurerm_postgresql_firewall_rule" "firewall_postgres" {
  name                = "pgfr-${local.name}"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.database.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Don't do this in real examples... This is just for demo purposes.
output "pg_password" {
  value = random_password.password.result
  sensitive = true
}

output "pg_user"{
  value = "${azurerm_postgresql_server.database.administrator_login}@${azurerm_postgresql_server.database.name}"
  sensitive = true
}