output "database_type" {
  description = "Created database type: aurora or rds"
  value       = var.use_aurora ? "aurora" : "rds"
}

output "endpoint" {
  description = "Primary database endpoint"
  value = var.use_aurora ? (
    aws_rds_cluster.main[0].endpoint
    ) : (
    aws_db_instance.main[0].address
  )
}

output "port" {
  description = "Database port"
  value       = local.database_port
}

output "database_name" {
  description = "Initial database name"
  value       = var.database_name
}

output "security_group_id" {
  description = "Security group ID used by the database"
  value       = aws_security_group.database.id
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "parameter_group_name" {
  description = "Parameter group name"
  value = var.use_aurora ? (
    aws_rds_cluster_parameter_group.aurora[0].name
    ) : (
    aws_db_parameter_group.rds[0].name
  )
}

output "rds_instance_id" {
  description = "Standard RDS instance ID"
  value = var.use_aurora ? null : (
    aws_db_instance.main[0].id
  )
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID"
  value = var.use_aurora ? (
    aws_rds_cluster.main[0].id
  ) : null
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value = var.use_aurora ? (
    aws_rds_cluster.main[0].reader_endpoint
  ) : null
}