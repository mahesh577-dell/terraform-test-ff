variable "project_id" {
  description = "GCP Project ID — must exist before running bootstrap"
  type        = string
}

variable "region" {
  description = "GCP Region for state buckets"
  type        = string
  default     = "asia-south1"
}
