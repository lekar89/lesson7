from django.http import JsonResponse
from django.urls import path


def home(request):
    return JsonResponse(
        {
            "status": "ok",
            "message": "Django application is running in Kubernetes",
        }
    )


urlpatterns = [
    path("", home),
]