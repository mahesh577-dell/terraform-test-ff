# ═══════════════════════════════════════════════════════════════
# BOOTSTRAP — One Time Setup
#
# PURPOSE:
# Creates prerequisites that must exist BEFORE
# any other Terraform code can run.
#
# WHY SEPARATE?
# Terraform needs a GCS bucket to store state files.
# But you can't use Terraform to create the bucket
# that Terraform itself needs → "chicken and egg" problem.
# Bootstrap solves this by using LOCAL state.
#
# RUN ORDER:
# Step 1 → Run THIS bootstrap manually (once ever!)
# Step 2 → Run environments/shared via CircleCI
# Step 3 → Run environments/tms-dev via CircleCI
# Step 4 → All other environments via CircleCI
#
# HOW TO RUN:
# cd terraform/bootstrap
# terraform init    ← uses local state (no GCS needed)
# terraform apply
# ═══════════════════════════════════════════════════════════════

# ── Enable required GCP APIs ──────────────────────────────────
# These APIs must be enabled before any resource can be created
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",              # VPC, Subnets, GCE, Firewall
    "container.googleapis.com",            # GKE clusters
    "sqladmin.googleapis.com",             # Cloud SQL (RDS equivalent)
    "artifactregistry.googleapis.com",     # Artifact Registry (ECR equivalent)
    "run.googleapis.com",                  # Cloud Run (ECS Fargate equivalent)
    "secretmanager.googleapis.com",        # Secret Manager (Secrets Manager equivalent)
    "cloudkms.googleapis.com",             # KMS encryption keys
    "servicenetworking.googleapis.com",    # PSA for Cloud SQL private IP
    "iam.googleapis.com",                  # IAM service accounts
    "cloudresourcemanager.googleapis.com", # Project management
    "storage.googleapis.com",             # GCS buckets
    "storagetransfer.googleapis.com",     # S3 → GCS migration
    "dns.googleapis.com",                 # Cloud DNS
    "monitoring.googleapis.com",          # Cloud Monitoring
    "logging.googleapis.com",             # Cloud Logging
    "cloudbuild.googleapis.com",          # Cloud Build (Jenkins equivalent)
    "vpcaccess.googleapis.com",           # VPC Access for Cloud Run
    "datamigration.googleapis.com",       # Database Migration Service
  ])

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false  # Keep APIs enabled even after terraform destroy
  disable_dependent_services = false
}

# ── GCS State Buckets ─────────────────────────────────────────
# One bucket per environment to store Terraform state
# These buckets MUST exist before running any environment code

locals {
  # All environments that need state buckets
  environments = [
    "shared",
    "tms-dev",
    "tms-staging",
    "tms-prod",
    "vms-dev",
    "vms-staging",
    "vms-prod",
    "analytics-dev",
    "analytics-prod",
  ]
}

resource "google_storage_bucket" "tfstate" {
  for_each = toset(local.environments)

  project                     = var.project_id
  name                        = "freightfox-tfstate-${each.value}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false  # Prevent accidental deletion

  # Keep last 5 versions of state file
  versioning {
    enabled = true
  }

  # Auto-delete old state versions after 90 days
  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    purpose     = "terraform-state"
    environment = each.value
    managed_by  = "terraform-bootstrap"
    owner       = "ankercloud"
  }
}

# ── CircleCI Service Account ──────────────────────────────────
# This SA is used by CircleCI to deploy infrastructure
# Its JSON key is added to CircleCI as GOOGLE_CREDENTIALS

resource "google_service_account" "circleci" {
  project      = var.project_id
  account_id   = "circleci-terraform"
  display_name = "CircleCI Terraform Deployer"
  description  = "Used by CircleCI to run terraform plan and apply"
}

# Give CircleCI SA permission to create infrastructure
resource "google_project_iam_member" "circleci_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.circleci.email}"
}

# Give CircleCI SA permission to manage state buckets
resource "google_project_iam_member" "circleci_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.circleci.email}"
}

# Output key instructions
output "next_steps" {
  value = <<-EOT
    ✅ Bootstrap complete!

    Next steps:
    1. Create CircleCI SA key:
       gcloud iam service-accounts keys create circleci-key.json \
         --iam-account=${google_service_account.circleci.email}

    2. Add key to CircleCI:
       CircleCI → Org Settings → Contexts → gcp-credentials
       Add: GOOGLE_CREDENTIALS = content of circleci-key.json

    3. State buckets created:
    ${join("\n    ", [for env in local.environments : "gs://freightfox-tfstate-${env}"])}

    4. Now push code to GitHub and let CircleCI run!
  EOT
}
