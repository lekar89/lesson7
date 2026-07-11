variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "8.5.6"
}

variable "service_type" {
  description = "Service type for Argo CD server"
  type        = string
  default     = "LoadBalancer"
}

variable "git_repo_url" {
  description = "Git repository URL containing the Django Helm chart"
  type        = string
}

variable "git_revision" {
  description = "Git branch monitored by Argo CD"
  type        = string
  default     = "lesson-8-9"
}

variable "chart_path" {
  description = "Path to the Django Helm chart inside the Git repository"
  type        = string
  default     = "charts/django-app"
}

variable "application_name" {
  description = "Name of the Argo CD Application"
  type        = string
  default     = "django-app"
}

variable "destination_namespace" {
  description = "Namespace where Django will be deployed"
  type        = string
  default     = "default"
}