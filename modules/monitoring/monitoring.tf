resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace

    labels = {
      app       = "monitoring"
      managedBy = "terraform"
    }
  }
}

resource "helm_release" "monitoring" {
  name       = var.release_name
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  set = [
    {
      name  = "grafana.adminUser"
      value = var.grafana_admin_user
    },
    {
      name  = "grafana.adminPassword"
      value = var.grafana_admin_password
    }
  ]

  timeout         = 1200
  wait            = true
  atomic          = false
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}