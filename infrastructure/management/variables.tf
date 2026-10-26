variable "admin_cidr" {
  description = "Administrator's public IPv4 address with a /32 suffix."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      can(regex("/32$", var.admin_cidr))
    )
    error_message = "Provide one IPv4 address with /32, for example 203.0.113.10/32."
  }
}

variable "ssh_public_key_path" {
  description = "Local path to the public SSH key for Jenkins servers."
  type        = string
  default     = "~/.ssh/hv-capstone.pub"
}
