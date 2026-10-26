data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_instance" "jenkins" {
  for_each = {
    controller = aws_security_group.jenkins_controller.id
    agent      = aws_security_group.jenkins_agent.id
  }

  ami                         = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.management_public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [each.value]
  key_name                    = aws_key_pair.jenkins.key_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins[each.key].name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "hv-capstone-jenkins-${each.key}"
    Role = each.key
  }

  depends_on = [
    aws_route_table_association.management_public,
    aws_iam_role_policy_attachment.systems_manager
  ]
}
