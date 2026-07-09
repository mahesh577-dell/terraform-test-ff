# ═══════════════════════════════════════════════════════════════
# MODULE: Cloud NAT
# AWS EQUIVALENT: AWS NAT Gateway
#
# PURPOSE:
# Private VMs have NO public IP (security best practice).
# But they need internet access for:
# → docker pull from Artifact Registry
# → apt-get install packages
# → Calling external APIs
# → Migration scripts connecting to AWS
#
# Cloud NAT provides OUTBOUND internet for private VMs
# WITHOUT giving them a public IP address.
#
# IMPORTANT:
# Applied ONLY to private subnets (GCE VMs need internet)
# NOT applied to data subnets (Cloud SQL is Google managed)
# ═══════════════════════════════════════════════════════════════

resource "google_compute_router_nat" "nat" {
  project = var.project_id
  name    = var.nat_name
  router  = var.router_name
  region  = var.region

  # Let Google auto-assign NAT IPs (simpler, no IP management)
  nat_ip_allocate_option = "AUTO_ONLY"

  # Only NAT the subnets we specify (not ALL subnets)
  # This is important — we don't want data subnets going through NAT
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Loop through each private subnet and add it to NAT
  dynamic "subnetwork" {
    for_each = var.private_subnet_self_links
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  # Log only errors (not all NAT traffic — too noisy and expensive)
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
