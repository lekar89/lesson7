variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "lesson-db-module"
}

variable "use_aurora" {
  description = "Create Aurora cluster when true, otherwise create a standard RDS instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where the database resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "engine" {
  description = "Database engine: postgres or mysql"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "engine must be either postgres or mysql."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = null
  nullable    = true
}

variable "instance_class" {
  description = "Instance class for RDS or Aurora instances"
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master database username"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Database port. Null selects the default port for the engine"
  type        = number
  default     = null
  nullable    = true
}

variable "allocated_storage" {
  description = "Allocated storage in GiB for a standard RDS instance"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB for a standard RDS instance"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for a standard RDS instance"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Enable Multi-AZ for a standard RDS instance"
  type        = bool
  default     = false
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances in the cluster"
  type        = number
  default     = 1

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "aurora_instance_count must be at least 1."
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the database"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Protect the database from accidental deletion"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Make a standard RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "max_connections" {
  description = "Value for the max_connections database parameter"
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Value for the PostgreSQL log_statement parameter"
  type        = string
  default     = "none"
}

variable "work_mem" {
  description = "Value for the PostgreSQL work_mem parameter"
  type        = string
  default     = "4096"
}

variable "tags" {
  description = "Additional tags for database resources"
  type        = map(string)
  default     = {}
}