variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "router_name" {
  description = "Router name"
  type        = string
}

variable "vpc_self_link" {
  description = "VPC self link"
  type        = string
}

variable "bgp_asn" {
  description = "BGP ASN unique per router"
  type        = number
  default     = 64514
}
