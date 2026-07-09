# ═══════════════════════════════════════════════════════════════
# MODULE: Cloudflare ZTNA Connector
#
# STATUS: PLACEHOLDER — Not deployed yet
#
# PURPOSE:
# Cloudflare Zero Trust Network Access (ZTNA) replaces VPN.
# Instead of giving developers VPN access to entire network,
# ZTNA gives access only to specific applications.
#
# HOW IT WORKS:
# 1. Small connector VM runs inside GCP VPC
# 2. Connector calls OUT to Cloudflare (no inbound ports needed)
# 3. Developers authenticate via Cloudflare
# 4. Cloudflare routes to the specific app via connector
#
# PENDING DECISION:
# Client needs to confirm inter-project communication patterns
# before we decide connector placement:
#
# Option A — One per VPC (8 connectors):
#   → If each project is fully isolated
#   → Code lives in each environment folder
#
# Option B — One per env group (3 connectors):
#   → If tms-dev + vms-dev communicate (via VPC peering)
#   → Code lives in environments/shared/
#
# TODO: Implement after client confirms communication patterns
# ═══════════════════════════════════════════════════════════════

# Placeholder — will be implemented after ZTNA decision
# resource "google_compute_instance" "ztna_connector" { ... }

output "status" {
  value = "ZTNA connector — pending deployment decision from client"
}
