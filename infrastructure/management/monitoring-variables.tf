variable "monitoring_source_cidr" {
  description = "EKS NAT Gateway public IPv4 /32 used for Jenkins metrics scraping."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.monitoring_source_cidr)) &&
      can(regex("/32$", var.monitoring_source_cidr))
    )
    error_message = "Provide the EKS NAT Gateway public IPv4 address with /32."
  }
}
