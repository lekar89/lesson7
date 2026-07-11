resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.project_name}-aurora"

  engine         = local.aurora_engine
  engine_version = var.engine_version

  database_name   = var.database_name
  master_username = var.username
  master_password = var.password
  port            = local.database_port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name

  backup_retention_period = var.backup_retention_period

  storage_encrypted   = true
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  apply_immediately   = true

  copy_tags_to_snapshot = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-aurora"
    }
  )
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier = "${var.project_name}-aurora-${count.index + 1}"

  cluster_identifier = aws_rds_cluster.main[0].id

  instance_class = var.instance_class
  engine         = local.aurora_engine
  engine_version = var.engine_version

  db_subnet_group_name = aws_db_subnet_group.main.name

  publicly_accessible = var.publicly_accessible

  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-aurora-${count.index + 1}"
      Role = count.index == 0 ? "writer" : "reader"
    }
  )
}