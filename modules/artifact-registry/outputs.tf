output "registry_url" {
  description = "Full Artifact Registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/freightfox"
}

output "repository_id" {
  value = google_artifact_registry_repository.freightfox.repository_id
}
