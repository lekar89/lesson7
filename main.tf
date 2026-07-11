terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "lesson-7"
      ManagedBy = "Terraform"
      Owner     = "Vladyslav"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name = "lesson-7"
  cluster_name = "lesson-7-eks"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "lesson-7-django"
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "lesson-7-eks"
  node_group_name = "lesson-7-nodes"

  subnet_ids = module.vpc.public_subnet_ids

  instance_types = ["t3.micro"]

  desired_size = 3
  min_size     = 2
  max_size     = 3
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint

  cluster_ca_certificate = base64decode(
    module.eks.cluster_certificate_authority_data
  )

  token = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host = module.eks.cluster_endpoint

    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )

    token = data.aws_eks_cluster_auth.main.token
  }
}

module "jenkins" {
  source = "./modules/jenkins"

  namespace      = "jenkins"
  release_name   = "jenkins"
  chart_version  = "5.9.25"
  service_type   = "LoadBalancer"
  admin_user     = "admin"
  admin_password = "admin12345"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  namespace             = "argocd"
  release_name          = "argocd"
  chart_version         = "8.5.6"
  service_type          = "LoadBalancer"
  git_repo_url          = "https://github.com/lekar89/lesson7.git"
  git_revision          = "lesson-8-9"
  chart_path            = "charts/django-app"
  application_name      = "django-app"
  destination_namespace = "default"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]
}