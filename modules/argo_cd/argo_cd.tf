resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.namespace

    labels = {
      app       = "argocd"
      managedBy = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = var.release_name
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  set = [
    {
      name  = "server.service.type"
      value = var.service_type
    }
  ]

  timeout         = 1200
  wait            = true
  atomic          = false
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  chart     = "${path.module}/charts"

  values = [
    file("${path.module}/charts/values.yaml")
  ]

  set = [
    {
      name  = "repositories[0].url"
      value = var.git_repo_url
    },
    {
      name  = "applications[0].source.repoURL"
      value = var.git_repo_url
    },
    {
      name  = "applications[0].source.targetRevision"
      value = var.git_revision
    },
    {
      name  = "applications[0].source.path"
      value = var.chart_path
    },
    {
      name  = "applications[0].name"
      value = var.application_name
    },
    {
      name  = "applications[0].destination.namespace"
      value = var.destination_namespace
    }
  ]

  timeout         = 600
  wait            = true
  atomic          = false
  cleanup_on_fail = true

  depends_on = [
    helm_release.argocd
  ]
}