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