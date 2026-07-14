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

variable "database_password" {
  description = "Master password for RDS or Aurora"
  type        = string
  sensitive   = true
}

variable "use_aurora" {
  description = "Create Aurora when true, otherwise create standard RDS"
  type        = bool
  default     = false
}

variable "database_engine" {
  description = "Database engine: postgres or mysql"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.database_engine)
    error_message = "database_engine must be postgres or mysql."
  }
}

variable "database_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.4"
}

variable "database_instance_class" {
  description = "Instance class for RDS or Aurora"
  type        = string
  default     = "db.t3.micro"
}

variable "database_multi_az" {
  description = "Enable Multi-AZ for standard RDS"
  type        = bool
  default     = false
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