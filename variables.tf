variable "jenkins_admin_user" {
  description = "Jenkins administrator username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}

variable "github_repository_url" {
  description = "GitHub repository monitored by Argo CD"
  type        = string
  default     = "https://github.com/lekar89/lesson7.git"
}

variable "github_branch" {
  description = "Git branch monitored by Argo CD and updated by Jenkins"
  type        = string
  default     = "lesson-8-9"
}