resource "kubernetes_secret_v1" "django_app" {
  metadata {
    name      = "django-app-secret"
    namespace = "default"

    annotations = {
      "argocd.argoproj.io/sync-options" = "Prune=false"
    }

    labels = {
      app       = "django-app"
      managedBy = "terraform"
    }
  }

  type = "Opaque"

  data = {
    DJANGO_SECRET_KEY = var.django_secret_key
    POSTGRES_PASSWORD = var.database_password
  }

  depends_on = [
    module.eks
  ]
}
