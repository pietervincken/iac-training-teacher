output "rg_runtime" {
  value = azurerm_resource_group.rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}

output "name_servers" {
  value = azurerm_dns_zone.domain.name_servers
}

output "domain" {
  value = azurerm_dns_zone.domain.name
}

output "external_dns_client_id" {
  value = azurerm_user_assigned_identity.external_dns_operator.client_id
}

output "external_dns_resource_id" {
  value = azurerm_user_assigned_identity.external_dns_operator.id
}
