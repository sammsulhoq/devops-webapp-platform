data "aws_iam_role" "operator" {
  name = var.operator_role_name
}

data "aws_iam_role" "jenkins_agent" {
  name = var.jenkins_agent_role_name
}

resource "aws_eks_access_entry" "administrators" {
  for_each = {
    operator      = data.aws_iam_role.operator.arn
    jenkins_agent = data.aws_iam_role.jenkins_agent.arn
  }

  cluster_name  = aws_eks_cluster.platform.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "administrators" {
  for_each = aws_eks_access_entry.administrators

  cluster_name  = aws_eks_cluster.platform.name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
