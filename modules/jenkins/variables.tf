variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.117"
}

variable "service_type" {
  description = "Kubernetes service type for Jenkins"
  type        = string
  default     = "LoadBalancer"
}

variable "admin_user" {
  description = "Jenkins administrator username"
  type        = string
}

variable "admin_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "Persistent volume size for Jenkins"
  type        = string
  default     = "5Gi"
}

variable "controller_service_account_name" {
  description = "Service account used by the Jenkins controller"
  type        = string
  default     = "jenkins-controller"
}

variable "agent_service_account_name" {
  description = "Service account used by Jenkins Kubernetes agents"
  type        = string
  default     = "jenkins-agent"
}