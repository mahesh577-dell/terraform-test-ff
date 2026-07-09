resource "google_artifact_registry_repository" "freightfox" {
  project       = var.project_id
  location      = var.region
  repository_id = "freightfox"
  description   = "FreightFox container images for ${var.environment} environment"
  format        = "DOCKER"

  labels = {
    environment = var.environment
    product     = "freightfox"
    managed_by  = "terraform"
    owner       = "ankercloud"
  }
}
