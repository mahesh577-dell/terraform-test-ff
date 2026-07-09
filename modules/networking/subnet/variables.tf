variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "vpc_name" {
  description = "VPC name"
  type        = string
}
variable "flow_sampling" {
  description = "Flow log sampling rate"
  type        = number
  default     = 0.1
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
