output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.main.node_group_name
}
output "ebs_csi_irsa_role_arn" {
  description = "IAM role ARN used by the Amazon EBS CSI driver"
  value       = aws_iam_role.ebs_csi_irsa_role.arn
}

output "ebs_csi_addon_name" {
  description = "Amazon EBS CSI EKS add-on name"
  value       = aws_eks_addon.ebs_csi_driver.addon_name
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc.arn
}