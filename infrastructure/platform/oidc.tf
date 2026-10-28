resource "aws_iam_openid_connect_provider" "platform" {
  url = aws_eks_cluster.platform.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]
}
