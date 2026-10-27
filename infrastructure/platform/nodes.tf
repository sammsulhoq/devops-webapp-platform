resource "aws_eks_node_group" "application" {
  cluster_name    = aws_eks_cluster.platform.name
  node_group_name = "hv-capstone-workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    for subnet in aws_subnet.private : subnet.id
  ]

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 30

  scaling_config {
    min_size     = 2
    desired_size = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes,
    aws_route_table_association.private
  ]

  tags = {
    Name = "hv-capstone-workers"
  }
}
