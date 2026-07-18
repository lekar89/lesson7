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

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "final-project"
      ManagedBy = "Terraform"
      Owner     = "Vladyslav"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name = "final-project"
  cluster_name = "final-project-eks"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

module "rds" {
  source = "./modules/rds"

  project_name = "final-project"

  use_aurora = var.use_aurora

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [
    "10.0.0.0/16"
  ]

  engine         = var.database_engine
  engine_version = var.database_engine_version
  instance_class = var.database_instance_class

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.database_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  multi_az              = var.database_multi_az
  publicly_accessible   = false
  deletion_protection   = false
  skip_final_snapshot   = true
  aurora_instance_count = 1

  max_connections = "100"
  log_statement   = "none"
  work_mem        = "4096"

  tags = {
    Environment = "final"
    Lesson      = "final-project"
  }
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "final-project-django"
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "final-project-eks"
  node_group_name = "final-project-nodes"

  cluster_subnet_ids = concat(
    module.vpc.public_subnet_ids,
    module.vpc.private_subnet_ids
  )

  node_subnet_ids = module.vpc.private_subnet_ids

  instance_types = ["t3.small"]

  desired_size = 4
  min_size     = 3
  max_size     = 5
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
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.1"

  set = [
    {
      name  = "args[0]"
      value = "--kubelet-preferred-address-types=InternalIP"
    },
    {
      name  = "args[1]"
      value = "--kubelet-insecure-tls"
    }
  ]

  timeout         = 600
  wait            = true
  cleanup_on_fail = true

  depends_on = [
    module.eks
  ]
}

module "jenkins" {
  source = "./modules/jenkins"

  namespace      = "jenkins"
  release_name   = "jenkins"
  chart_version  = "5.9.25"
  service_type   = "LoadBalancer"
  admin_user     = var.jenkins_admin_user
  admin_password = var.jenkins_admin_password


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
  git_repo_url          = var.github_repository_url
  git_revision          = var.github_branch
  chart_path            = "charts/django-app"
  application_name      = "django-app"
  destination_namespace = "default"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks,
    kubernetes_secret_v1.django_app
  ]

}

module "monitoring" {
  source = "./modules/monitoring"

  namespace              = "monitoring"
  release_name           = "monitoring"
  chart_version          = "83.6.0"
  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]
}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name         = "terraform-state-bucket-vl-01"
  dynamodb_table_name = "terraform-locks"

  tags = {
    Project = "final-project"
    Lesson  = "final"
  }
}