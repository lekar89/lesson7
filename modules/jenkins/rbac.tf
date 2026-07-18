resource "kubernetes_service_account_v1" "jenkins_controller" {
  metadata {
    name      = var.controller_service_account_name
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

    labels = {
      app       = "jenkins"
      component = "controller"
      managedBy = "terraform"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_service_account_v1" "jenkins_agent" {
  metadata {
    name      = var.agent_service_account_name
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

    labels = {
      app       = "jenkins"
      component = "agent"
      managedBy = "terraform"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_role_v1" "jenkins_controller" {
  metadata {
    name      = "jenkins-controller"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

    labels = {
      app       = "jenkins"
      managedBy = "terraform"
    }
  }

  rule {
    api_groups = [""]

    resources = [
      "pods",
      "pods/status"
    ]

    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "watch",
      "patch",
      "update"
    ]
  }

  rule {
    api_groups = [""]

    resources = [
      "pods/exec",
      "pods/attach"
    ]

    verbs = [
      "create",
      "get"
    ]
  }

  rule {
    api_groups = [""]

    resources = [
      "pods/log"
    ]

    verbs = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [""]

    resources = [
      "configmaps",
      "secrets",
      "services",
      "serviceaccounts"
    ]

    verbs = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [""]

    resources = [
      "events"
    ]

    verbs = [
      "create",
      "get",
      "list",
      "watch",
      "patch",
      "update"
    ]
  }
}

resource "kubernetes_role_binding_v1" "jenkins_controller" {
  metadata {
    name      = "jenkins-controller"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

    labels = {
      app       = "jenkins"
      managedBy = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.jenkins_controller.metadata[0].name
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.jenkins_controller.metadata[0].name
  }
}