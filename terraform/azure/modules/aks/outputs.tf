# output "kubernetes_host" {
#   value = azurerm_kubernetes_cluster.aks.kube_config.0.host
#   sensitive = true
# }

# output "client_certificate" {
#   value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
#   sensitive = true
# }

# output "client_key" {
#   value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
#   sensitive = true
# }

# output "cluster_ca_certificate" {
#   value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
#   sensitive = true
# }

# output "private_ingressgateway_ip" {
#   value = var.private_ingressgateway_ip
# }

output "kubernetes_host" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "client_certificate" {
  value     = module.eks.cluster_certificate_authority[0].data
  sensitive = true
}

output "client_key" {
  value     = null  # AWS EKS does not provide client key in the same way Azure AKS does, so this output is not applicable
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.eks.cluster_certificate_authority[0].data
  sensitive = true
}

output "private_ingressgateway_ip" {
  value     = var.private_ingressgateway_ip
}
