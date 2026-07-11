output "namespace" {
  description = "Kubernetes namespace where Jenkins is installed"
  value       = kubernetes_namespace_v1.jenkins.metadata[0].name
}

output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "service_name" {
  description = "Jenkins controller service name"
  value       = helm_release.jenkins.name
}

output "admin_user" {
  description = "Jenkins administrator username"
  value       = var.admin_user
}

output "admin_password" {
  description = "Jenkins administrator password"
  value       = var.admin_password
  sensitive   = true
}