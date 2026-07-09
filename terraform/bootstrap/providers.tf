terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # ⚠️ IMPORTANT: Bootstrap uses LOCAL backend
  # This is intentional — bootstrap CREATES the GCS buckets
  # that all other environments use as remote backend.
  # Do NOT change this to a GCS backend!
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
