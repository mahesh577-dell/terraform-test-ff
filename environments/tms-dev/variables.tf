variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "tms-dev-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.60.0.0/16"
}

variable "subnets" {
  description = "Map of subnets"
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
