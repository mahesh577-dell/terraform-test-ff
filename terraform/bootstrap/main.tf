# ═══════════════════════════════════════════════════════════════
# BOOTSTRAP — Run ONCE manually before anything else
# Uses LOCAL backend — creates the GCS buckets for all envs
# ═══════════════════════════════════════════════════════════════

# Enable all required GCP APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "dns.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudkms.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Create GCS state buckets for all environments
locals {
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
  force_destroy               = false

  versioning {
    enabled = true
  }

  labels = {
    purpose    = "terraform-state"
    managed_by = "terraform-bootstrap"
  }
}

# CircleCI Service Account
resource "google_service_account" "circleci" {
  project      = var.project_id
  account_id   = "circleci-terraform"
  display_name = "CircleCI Terraform Deployer"
}

resource "google_project_iam_member" "circleci_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.circleci.email}"
}

resource "google_project_iam_member" "circleci_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.circleci.email}"
}
