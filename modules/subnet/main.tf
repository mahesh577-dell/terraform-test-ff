# ═══════════════════════════════════════════════════════════════
# MODULE: Subnet
# AWS EQUIVALENT: AWS Subnet
#
# Creates subnets following Plan A:
# .1.0/24 → public-1a   (Load Balancer, Bastion)
# .2.0/24 → public-1b   (Load Balancer)
# .3.0/24 → private-1a  (GKE nodes, GCE, Cloud Run)
# .4.0/24 → private-1b  (GKE nodes, GCE)
# .5.0/24 → data-1a     (Cloud SQL)
# .6.0/24 → data-1b     (Cloud SQL)
# .7.0/24 → data-1c     (Cloud SQL — matches AWS 3rd AZ)
#
# FEATURES:
# - Private Google Access ON → private VMs can reach Google APIs
# - Flow logs ON → for security auditing (0.1 sampling = dev)
# - Supports secondary ranges for GKE pods/services
# ═══════════════════════════════════════════════════════════════

resource "google_compute_subnetwork" "subnet" {
  # Create one subnet per entry in var.subnets list
  for_each = { for s in var.subnets : s.name => s }

  project       = var.project_id
  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = var.vpc_self_link
  description   = lookup(each.value, "description", "")

  # Allows private VMs to access Google APIs (e.g. Artifact Registry)
  # without needing a public IP or NAT
  private_ip_google_access = true

  # Secondary ranges for GKE pods and services
  # Only needed for subnets that run GKE node pools
  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  # Flow logs — captures network traffic for security auditing
  # flow_sampling = 0.1 means 10% sampling (cost saving for dev)
  # Use 0.5 for staging, 1.0 for prod
  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = var.flow_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
