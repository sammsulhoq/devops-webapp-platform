resource "aws_eks_addon" "metrics_server" {
  cluster_name = aws_eks_cluster.platform.name
  addon_name   = "metrics-server"
}
