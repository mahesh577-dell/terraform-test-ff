variable "project_id"    { description = "GCP Project ID"; type = string }
variable "region"        { description = "GCP Region"; type = string; default = "asia-south1" }
variable "vpc_self_link" { description = "VPC self link"; type = string }
variable "flow_sampling" { description = "Flow log sampling rate (0.1=dev, 0.5=staging, 1.0=prod)"; type = number; default = 0.1 }

variable "subnets" {
  description = "List of subnets to create — follows Plan A design"
  type = list(object({
    name        = string
    cidr        = string
    description = optional(string, "")
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}
