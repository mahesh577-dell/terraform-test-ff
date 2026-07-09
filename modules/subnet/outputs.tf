output "subnet_self_links" { value = { for k, v in google_compute_subnetwork.subnet : k => v.self_link } }
output "subnet_cidrs"      { value = { for k, v in google_compute_subnetwork.subnet : k => v.ip_cidr_range } }
output "subnet_ids"        { value = { for k, v in google_compute_subnetwork.subnet : k => v.id } }
