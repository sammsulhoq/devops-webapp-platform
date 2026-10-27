variable "admin_cidr" {
  description = "Administrator's public IPv4 address with a /32 suffix."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      can(regex("/32$", var.admin_cidr))
    )
    error_message = "Provide one IPv4 address with /32."
  }
}

variable "operator_role_name" {
  description = "IAM Identity Center role used by the project operator."
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess_b6cf4a592982cb4c"
}

variable "jenkins_agent_role_name" {
  description = "IAM role attached to the Jenkins build agent."
  type        = string
  default     = "hv-capstone-jenkins-agent"
}
