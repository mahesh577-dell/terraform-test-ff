output "subnets" {
  description = "Map of subnet name to subnet object"
  value       = google_compute_subnetwork.subnet
}

output "subnet_self_links" {
  description = "Map of subnet name to self link"
  value       = { for k, v in google_compute_subnetwork.subnet : k => v.self_link }
}

output "subnet_cidrs" {
  description = "Map of subnet name to CIDR"
  value       = { for k, v in google_compute_subnetwork.subnet : k => v.ip_cidr_range }
}
