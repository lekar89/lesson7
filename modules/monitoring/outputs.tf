output "namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "release_name" {
  description = "Monitoring Helm release name"
  value       = helm_release.monitoring.name
}

output "grafana_service_name" {
  description = "Grafana Kubernetes service name"
  value       = "${helm_release.monitoring.name}-grafana"
}

output "prometheus_service_name" {
  description = "Prometheus Kubernetes service name"
  value       = "${helm_release.monitoring.name}-kube-prometheus-prometheus"
}