terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "freightfox-tfstate-tms-dev"
    prefix = "terraform/tms-dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
