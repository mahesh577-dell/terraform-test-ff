# ═══════════════════════════════════════════════════════════════
# MODULE: Cloud Router
# AWS EQUIVALENT: AWS Transit Gateway (basic routing)
#
# PURPOSE:
# Cloud Router is the "brain" of the network.
# Required for:
# 1. Cloud NAT → private VMs need internet (docker pull, apt etc)
# 2. VPN tunnel → future AWS ↔ GCP connectivity
# 3. Dynamic routing between VPCs
#
# BGP ASN allocation (must be unique per router):
# tms-dev     → 64514
# tms-staging → 64515
# tms-prod    → 64516
# vms-dev     → 64517
# vms-staging → 64518
# vms-prod    → 64519
# ═══════════════════════════════════════════════════════════════

resource "google_compute_router" "router" {
  project     = var.project_id
  name        = var.router_name
  region      = var.region
  network     = var.vpc_self_link
  description = "Cloud Router — enables NAT + future VPN to AWS"

  bgp {
    asn            = var.bgp_asn      # Unique BGP ID for this router
    advertise_mode = "DEFAULT"        # Advertise all subnets automatically
  }
}
