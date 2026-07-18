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
    },


    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = var.controller_service_account_name
    },
    {
      name  = "rbac.create"
      value = "false"
    },
    {
      name  = "agent.serviceAccount"
      value = var.agent_service_account_name
    }
  ]

  timeout         = 1200
  wait            = true
  atomic          = false
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace_v1.jenkins,
    kubernetes_service_account_v1.jenkins_controller,
    kubernetes_service_account_v1.jenkins_agent,
    kubernetes_role_v1.jenkins_controller,
    kubernetes_role_binding_v1.jenkins_controller

  ]
}