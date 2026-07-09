variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "vpc_name" {
  description = "VPC name"
  type        = string
}
variable "routing_mode" {
  description = "Routing mode"
  type        = string
  default     = "REGIONAL"
}
variable "description" {
  description = "VPC description"
  type        = string
  default     = "FreightFox VPC"
}
