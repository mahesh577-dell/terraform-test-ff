output "artifact_registry_url" {
  description = "Artifact Registry URL for all docker push/pull commands"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/freightfox"
}
