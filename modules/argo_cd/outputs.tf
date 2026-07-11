output "namespace" {
  description = "Kubernetes namespace where Argo CD is installed"
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argocd.name
}

output "server_service_name" {
  description = "Argo CD server service name"
  value       = "${helm_release.argocd.name}-server"
}

output "application_name" {
  description = "Argo CD Application name"
  value       = var.application_name
}