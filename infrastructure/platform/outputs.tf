output "ecr_repository_url" {
  description = "URL of the application container image repository."
  value       = aws_ecr_repository.application.repository_url
}

output "eks_cluster_name" {
  description = "Name of the application EKS cluster."
  value       = aws_eks_cluster.platform.name
}

output "eks_node_group_name" {
  description = "Name of the managed worker node group."
  value       = aws_eks_node_group.application.node_group_name
}
