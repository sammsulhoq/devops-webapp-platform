data "aws_instance" "jenkins_agent" {
  filter {
    name   = "tag:Name"
    values = ["hv-capstone-jenkins-agent"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

resource "aws_eks_cluster" "platform" {
  name     = "hv-capstone-dev"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.35"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids = concat(
      [for subnet in aws_subnet.public : subnet.id],
      [for subnet in aws_subnet.private : subnet.id]
    )

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = distinct([
      var.admin_cidr,
      "${data.aws_instance.jenkins_agent.public_ip}/32"
    ])
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}
