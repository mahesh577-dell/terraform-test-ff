variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC name to attach subnets"
  type        = string
}

variable "flow_sampling" {
  description = "Flow log sampling rate (0.1=dev, 0.5=staging, 1.0=prod)"
  type        = number
  default     = 0.1
}

variable "subnets" {
  description = "Map of subnets — defined in terraform.tfvars per environment"
  type = map(object({
    cidr                     = string
    region                   = string
    description              = optional(string, "")
    private_ip_google_access = optional(bool, false)
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = {}
}
