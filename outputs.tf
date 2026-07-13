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
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_public_ip
}