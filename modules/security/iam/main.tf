# ═══════════════════════════════════════════════════════════════
# MODULE: IAM (Identity and Access Management)
# AWS EQUIVALENT: AWS IAM
#
# PURPOSE:
# Manages service accounts and permissions.
# Each service gets a dedicated service account
# with ONLY the permissions it needs (least privilege).
#
# SERVICE ACCOUNTS CREATED PER ENVIRONMENT:
# → cloud-run-sa   → for Cloud Run services
# → gke-nodes-sa   → for GKE node pools
# → circleci-sa    → for CircleCI deployments
#
# STATUS: PLACEHOLDER — Bootstrap handles base IAM
# ═══════════════════════════════════════════════════════════════

output "status" {
  value = "IAM module — placeholder, base IAM handled by bootstrap"
}
