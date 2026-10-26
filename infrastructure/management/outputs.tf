output "vpc_id" {
  description = "Management VPC ID."
  value       = aws_vpc.management.id
}

output "jenkins_servers" {
  description = "Connection details for the Jenkins servers."
  value = {
    for role, instance in aws_instance.jenkins : role => {
      instance_id = instance.id
      public_ip   = instance.public_ip
      private_ip  = instance.private_ip
    }
  }
}

output "ubuntu_ami_id" {
  description = "Ubuntu image selected for the Jenkins servers."
  value       = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
}
