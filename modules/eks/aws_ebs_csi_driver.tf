data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

locals {
  eks_oidc_issuer = aws_eks_cluster.main.identity[0].oidc[0].issuer

  eks_oidc_provider = replace(
    local.eks_oidc_issuer,
    "https://",
    ""
  )
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url = local.eks_oidc_issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name      = "${var.cluster_name}-oidc-provider"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    sid     = "AllowEBSCSIDriverAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.oidc.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}

resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${var.cluster_name}-ebs-csi-irsa-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = {
    Name      = "${var.cluster_name}-ebs-csi-irsa-role"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_irsa_policy" {
  role = aws_iam_role.ebs_csi_irsa_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicyV2"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name      = "${var.cluster_name}-ebs-csi-driver"
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_irsa_policy
  ]
}