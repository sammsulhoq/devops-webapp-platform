resource "aws_security_group" "jenkins_configuration" {
  name_prefix = "hv-capstone-configuration-"
  description = "SSH from Jenkins agent for Ansible configuration"
  vpc_id      = aws_vpc.management.id

  ingress {
    description     = "Ansible SSH from Jenkins agent"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_agent.id]
  }

  tags = {
    Name = "hv-capstone-configuration-sg"
  }
}
