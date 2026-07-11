locals {
  database_port = var.port != null ? var.port : (
    var.engine == "mysql" ? 3306 : 5432
  )

  rds_engine_family = var.engine == "mysql" ? "mysql8.0" : "postgres16"

  aurora_engine = var.engine == "mysql" ? "aurora-mysql" : "aurora-postgresql"

  aurora_engine_family = var.engine == "mysql" ? "aurora-mysql8.0" : "aurora-postgresql16"

  common_tags = merge(
    {
      Project   = var.project_name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group"
    }
  )
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Security group for database access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Database access"
    from_port   = local.database_port
    to_port     = local.database_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-database-sg"
    }
  )
}

resource "aws_db_parameter_group" "rds" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.project_name}-rds-parameter-group"
  family = local.rds_engine_family

  dynamic "parameter" {
    for_each = var.engine == "postgres" ? {
      max_connections = var.max_connections
      log_statement   = var.log_statement
      work_mem        = var.work_mem
      } : {
      max_connections = var.max_connections
    }

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-rds-parameter-group"
    }
  )
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.project_name}-aurora-parameter-group"
  family = local.aurora_engine_family

  dynamic "parameter" {
    for_each = var.engine == "postgres" ? {
      max_connections = var.max_connections
      log_statement   = var.log_statement
      work_mem        = var.work_mem
      } : {
      max_connections = var.max_connections
    }

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-aurora-parameter-group"
    }
  )
}