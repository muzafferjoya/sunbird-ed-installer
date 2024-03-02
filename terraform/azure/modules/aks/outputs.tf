output "kubernetes_host" {
  value     = aws_eks_cluster.eks.endpoint
  sensitive = true
}

output "client_certificate" {
  value     = aws_eks_cluster.eks.certificate_authority.0.data
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = aws_eks_cluster.eks.certificate_authority.0.data
  sensitive = true
}
