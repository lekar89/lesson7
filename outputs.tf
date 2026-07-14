output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group"
  value       = module.eks.node_group_name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = module.jenkins.namespace
}

output "jenkins_release_name" {
  description = "Jenkins Helm release name"
  value       = module.jenkins.release_name
}

output "jenkins_admin_user" {
  description = "Jenkins administrator username"
  value       = module.jenkins.admin_user
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = module.argo_cd.namespace
}

output "argocd_release_name" {
  description = "Argo CD Helm release name"
  value       = module.argo_cd.release_name
}

output "argocd_application_name" {
  description = "Name of the Argo CD Application"
  value       = module.argo_cd.application_name
}


output "database_type" {
  description = "Created database type"
  value       = module.rds.database_type
}

output "database_endpoint" {
  description = "Primary database endpoint"
  value       = module.rds.endpoint
}

output "database_port" {
  description = "Database port"
  value       = module.rds.port
}

output "database_name" {
  description = "Initial database name"
  value       = module.rds.database_name
}

output "database_security_group_id" {
  description = "Security group ID used by the database"
  value       = module.rds.security_group_id
}

output "database_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds.subnet_group_name
}

output "database_parameter_group_name" {
  description = "Database parameter group name"
  value       = module.rds.parameter_group_name
}

output "rds_instance_id" {
  description = "Standard RDS instance ID"
  value       = module.rds.rds_instance_id
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID"
  value       = module.rds.aurora_cluster_id
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.rds.aurora_reader_endpoint
}
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_public_ip

}
output "jenkins_service_name" {
  description = "Jenkins controller service name"
  value       = module.jenkins.service_name

}
output "monitoring_namespace" {
  description = "Namespace where monitoring stack is installed"
  value       = module.monitoring.namespace
}

output "monitoring_release_name" {
  description = "Monitoring Helm release name"
  value       = module.monitoring.release_name
}

output "grafana_service_name" {
  description = "Grafana Kubernetes service name"
  value       = module.monitoring.grafana_service_name
}

output "prometheus_service_name" {
  description = "Prometheus Kubernetes service name"
  value       = module.monitoring.prometheus_service_name
}