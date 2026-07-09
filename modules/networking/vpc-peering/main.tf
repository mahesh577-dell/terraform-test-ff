# ═══════════════════════════════════════════════════════════════
# MODULE: VPC Peering
#
# STATUS: PLACEHOLDER — Not deployed yet
#
# PURPOSE:
# Connects two GCP VPCs so resources can communicate
# using private IPs without going through internet.
#
# EXAMPLE:
# tms-dev-vpc ←→ vms-dev-vpc
# Services in tms-dev can call services in vms-dev
# via private IP (10.60.x.x ↔ 10.63.x.x)
#
# REQUIREMENT:
# VPC CIDRs must NOT overlap (why we used 10.60-10.67)
# Our design: ✅ Zero overlaps verified
#
# PENDING:
# Client needs to confirm which projects communicate
# before we set up peering
# ═══════════════════════════════════════════════════════════════

# Placeholder — will be implemented after communication patterns confirmed
# resource "google_compute_network_peering" "peering" { ... }

output "status" {
  value = "VPC Peering — pending client confirmation of communication patterns"
}
