variable "project_id"  { description = "GCP Project ID"; type = string }
variable "vpc_name"    { description = "VPC name to attach rules to"; type = string }
variable "vpc_cidr"    { description = "VPC CIDR for internal traffic rule"; type = string }
variable "name_prefix" { description = "Prefix for rule names e.g. tms-dev"; type = string }
