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

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
