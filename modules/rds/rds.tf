resource "aws_db_instance" "main" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.project_name}-rds"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.username
  password = var.password
  port     = local.database_port

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.rds[0].name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  auto_minor_version_upgrade = true
  apply_immediately          = true

  copy_tags_to_snapshot = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-rds"
    }
  )
}