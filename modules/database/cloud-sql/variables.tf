variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "region" {
  description = "GCP Region"
  type        = string
}
variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}
variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_16"
}
variable "vpc_id" {
  description = "VPC network ID"
  type        = string
}
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "dev-services-db"
}
variable "secret_name" {
  description = "Secret Manager secret name"
  type        = string
  default     = "dev-service-db"
}
variable "db_peering_connection" {
  description = "PSA VPC peering connection ID"
  type        = string
}
