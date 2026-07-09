# ═══════════════════════════════════════════════════════════════
# ENVIRONMENT: tms-dev
#
# PROJECT  : ccd-poc-project (POC — will move to tms-dev-501607)
# VPC      : tms-dev-vpc
# CIDR     : 10.60.0.0/16
# REGION   : asia-south1 (Mumbai — same as AWS ap-south-1)
#
# WHAT THIS CREATES:
# 1. VPC                → tms-dev-vpc (10.60.0.0/16)
# 2. 7 Subnets (Plan A) → public/private/data zones
# 3. Firewall Rules     → secure default-deny setup
# 4. Cloud Router       → enables NAT + future AWS VPN
# 5. Cloud NAT          → private VMs can reach internet
#
# AWS EQUIVALENT:
# This replaces the AWS ff-dev-vpc (10.51.0.0/16) setup
# and its subnets/security groups/NAT gateway
#
# HOW TO DEPLOY:
# 1. Push to feature branch → CircleCI runs plan only
# 2. Merge to main         → CircleCI runs plan + approve + apply
# ═══════════════════════════════════════════════════════════════

# ── Common labels applied to all resources ────────────────────
# Labels help with:
# → Cost tracking (filter by environment or product)
# → Resource management (find all dev resources)
# → Compliance auditing (who owns what)
locals {
  common_labels = {
    environment = "dev"
    product     = "tms"
    project     = "freightfox"
    managed_by  = "terraform"
    owner       = "ankercloud"
  }
}

# ── 1. VPC ────────────────────────────────────────────────────
# Creates the main network for TMS DEV
# All resources (GKE, Cloud SQL, GCE) will live inside this VPC
module "vpc" {
  source      = "../../modules/vpc"
  project_id  = var.project_id
  vpc_name    = var.vpc_name
  description = "TMS DEV VPC — FreightFox (replaces AWS ff-dev-vpc 10.51.0.0/16)"
}

# ── 2. Subnets (Plan A) ───────────────────────────────────────
# Plan A: 7 subnets per VPC
# Public  (.1, .2) → internet-facing (Load Balancer, Bastion)
# Private (.3, .4) → app servers (GKE, GCE, Cloud Run)
# Data    (.5, .6, .7) → databases (Cloud SQL)
#
# Secondary ranges in private-1a for future GKE:
# pods range     → 10.60.16.0/20 (4094 IPs for K8s pods)
# services range → 10.60.32.0/20 (4094 IPs for K8s services)
module "subnets" {
  source        = "../../modules/subnet"
  project_id    = var.project_id
  region        = var.region
  vpc_self_link = module.vpc.vpc_self_link
  flow_sampling = 0.1  # 10% sampling for dev (cost saving)

  subnets = [
    # ── Public subnets ───────────────────────────────────────
    # Used for: Load Balancer, Bastion host, public-facing services
    {
      name        = "tms-dev-public-1a"
      cidr        = "10.60.1.0/24"
      description = "Public Zone A — Load Balancer / Bastion"
    },
    {
      name        = "tms-dev-public-1b"
      cidr        = "10.60.2.0/24"
      description = "Public Zone B — Load Balancer"
    },

    # ── Private subnets ──────────────────────────────────────
    # Used for: GKE node pools, GCE VMs, Cloud Run VPC connector
    # Has secondary ranges for GKE pods and services
    {
      name        = "tms-dev-private-1a"
      cidr        = "10.60.3.0/24"
      description = "Private Zone A — GKE Nodes / GCE / Cloud Run"
      secondary_ranges = [
        {
          range_name    = "tms-dev-pods"
          ip_cidr_range = "10.60.16.0/20"  # 4094 IPs for GKE pods
        },
        {
          range_name    = "tms-dev-services"
          ip_cidr_range = "10.60.32.0/20"  # 4094 IPs for GKE services
        }
      ]
    },
    {
      name        = "tms-dev-private-1b"
      cidr        = "10.60.4.0/24"
      description = "Private Zone B — GCE / App servers"
    },

    # ── Data subnets ─────────────────────────────────────────
    # Used for: Cloud SQL instances (private IP via PSA)
    # Equivalent to AWS DB subnet groups
    {
      name        = "tms-dev-data-1a"
      cidr        = "10.60.5.0/24"
      description = "Data Zone A — Cloud SQL (replaces AWS ff-dev-db-subnet-1a)"
    },
    {
      name        = "tms-dev-data-1b"
      cidr        = "10.60.6.0/24"
      description = "Data Zone B — Cloud SQL (replaces AWS ff-dev-db-subnet-1b)"
    },
    {
      name        = "tms-dev-data-1c"
      cidr        = "10.60.7.0/24"
      description = "Data Zone C — Cloud SQL (replaces AWS ff-dev-db-subnet-1c)"
    },
  ]

  depends_on = [module.vpc]
}

# ── 3. Firewall Rules ─────────────────────────────────────────
# Creates 6 firewall rules (see module for details)
# Key rules:
# → SSH only via IAP (no public SSH!)
# → Default deny all ingress
# → Allow outbound (for docker pull, apt etc)
module "firewall" {
  source      = "../../modules/firewall"
  project_id  = var.project_id
  vpc_name    = module.vpc.vpc_name
  vpc_cidr    = var.vpc_cidr
  name_prefix = "tms-dev"
  depends_on  = [module.vpc]
}

# ── 4. Cloud Router ───────────────────────────────────────────
# Required for Cloud NAT and future VPN to AWS
# BGP ASN 64514 = tms-dev (unique across all environments)
module "cloud_router" {
  source        = "../../modules/cloud_router"
  project_id    = var.project_id
  region        = var.region
  router_name   = "tms-dev-router"
  vpc_self_link = module.vpc.vpc_self_link
  bgp_asn       = 64514  # tms-dev unique ASN
  depends_on    = [module.vpc]
}

# ── 5. Cloud NAT ──────────────────────────────────────────────
# Allows private GCE VMs (ECS node equivalents) to:
# → Pull Docker images from Artifact Registry
# → Download packages (apt-get, pip etc)
# → Connect to external services
#
# Applied ONLY to private subnets
# Data subnets (Cloud SQL) don't need NAT
module "nat" {
  source      = "../../modules/nat"
  project_id  = var.project_id
  region      = var.region
  nat_name    = "tms-dev-nat"
  router_name = module.cloud_router.router_name

  # Only private subnets — NOT data subnets
  private_subnet_self_links = [
    module.subnets.subnet_self_links["tms-dev-private-1a"],
    module.subnets.subnet_self_links["tms-dev-private-1b"],
  ]

  depends_on = [module.cloud_router, module.subnets]
}
