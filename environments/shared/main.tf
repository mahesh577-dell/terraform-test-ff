# ═══════════════════════════════════════════════════════════════
# ENVIRONMENT: shared
#
# PURPOSE:
# Resources that are shared across ALL environments.
# Things that don't belong to any single environment.
#
# WHAT LIVES HERE:
# ✅ Artifact Registry — ONE repo for all Docker images
#    All environments (dev/staging/prod) push/pull here
#
# 🔜 Coming soon (pending decisions):
# → Org level IAM policies
# → Cloudflare DNS management
# → Cloudflare ZTNA connectors (pending client decision)
# → Budget alerts across all projects
# → VPC peering (pending communication pattern confirmation)
#
# WHY NOT IN EACH ENVIRONMENT:
# Artifact Registry created once here → all envs use it
# Avoids duplication and inconsistency
# ═══════════════════════════════════════════════════════════════

# ── Artifact Registry ─────────────────────────────────────────
# ONE registry for ALL FreightFox Docker images
# Replaces AWS ECR (070532166964.dkr.ecr.ap-south-1.amazonaws.com)
#
# Image path format:
# asia-south1-docker.pkg.dev/ccd-poc-project/freightfox/dev/aeolus:latest
# asia-south1-docker.pkg.dev/ccd-poc-project/freightfox/prod/kremlin:latest
resource "google_artifact_registry_repository" "freightfox" {
  project       = var.project_id
  location      = var.region
  repository_id = "freightfox"
  description   = "FreightFox container images — all environments (migrated from AWS ECR)"
  format        = "DOCKER"

  labels = {
    environment = "shared"
    product     = "freightfox"
    managed_by  = "terraform"
    owner       = "ankercloud"
  }
}

# ── Placeholder: Cloudflare ZTNA ──────────────────────────────
# TODO: Implement after client confirms inter-project communication
# module "ztna_dev" {
#   source = "../../modules/networking/cloudflare-ztna"
#   ...
# }

# ── Placeholder: VPC Peering ──────────────────────────────────
# TODO: Implement after client confirms which projects communicate
# module "tms_vms_dev_peering" {
#   source = "../../modules/networking/vpc-peering"
#   ...
# }
