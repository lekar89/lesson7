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
output "controller_service_account_name" {
  description = "Jenkins controller service account name"
  value       = kubernetes_service_account_v1.jenkins_controller.metadata[0].name
}

output "agent_service_account_name" {
  description = "Jenkins agent service account name"
  value       = kubernetes_service_account_v1.jenkins_agent.metadata[0].name
}