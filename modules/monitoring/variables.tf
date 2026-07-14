variable "namespace" {
  description = "Kubernetes namespace for Prometheus and Grafana"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "83.6.0"
}

variable "grafana_admin_user" {
  description = "Grafana administrator username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana administrator password"
  type        = string
  sensitive   = true
}