variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secret_name" {
  description = "Secret name"
  type        = string
}

variable "secret_value" {
  description = "Secret value to store"
  type        = string
  sensitive   = true
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
  default     = {}
}
