# ═══════════════════════════════════════════════════════════════
# MODULE: VPC
# AWS EQUIVALENT: AWS VPC
#
# Creates one custom VPC per GCP project.
# 8 projects = 8 VPCs (one per environment)
#
# CIDR Allocation (non-overlapping for VPN compatibility):
# tms-dev     → 10.60.0.0/16
# tms-staging → 10.61.0.0/16
# tms-prod    → 10.62.0.0/16
# vms-dev     → 10.63.0.0/16
# vms-staging → 10.64.0.0/16
# vms-prod    → 10.65.0.0/16
# analytics-dev  → 10.66.0.0/16
# analytics-prod → 10.67.0.0/16
# ═══════════════════════════════════════════════════════════════

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false  # Custom mode — we control all subnets
  routing_mode            = "REGIONAL"
  description             = var.description
}
