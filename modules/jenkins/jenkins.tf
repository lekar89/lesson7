resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace

    labels = {
      app       = "jenkins"
      managedBy = "terraform"
    }
  }
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  set = [
    {
      name  = "controller.serviceType"
      value = var.service_type
    },
    {
      name  = "controller.admin.username"
      value = var.admin_user
    },
    {
      name  = "controller.admin.password"
      value = var.admin_password
    }
  ]

  timeout         = 1200
  wait            = true
  atomic          = false
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace_v1.jenkins
  ]
}