variable "project_id"               { description = "GCP Project ID"; type = string }
variable "region"                   { description = "GCP Region"; type = string; default = "asia-south1" }
variable "nat_name"                 { description = "NAT name"; type = string }
variable "router_name"              { description = "Router name to attach NAT"; type = string }
variable "private_subnet_self_links" {
  description = "Private subnet self links to apply NAT (NOT data subnets)"
  type        = list(string)
}
