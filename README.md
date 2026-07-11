# Домашнє завдання до теми «Вивчення Helm»

У цьому проєкті реалізовано створення Kubernetes-кластера в AWS за допомогою Terraform, завантаження Docker-образу Django до Amazon ECR та розгортання застосунку в Amazon EKS за допомогою Helm.

## Реалізовано

* VPC із public та private subnet.
* Amazon EKS cluster.
* EKS Managed Node Group.
* Amazon ECR repository.
* Docker-образ Django.
* Helm chart для Django.
* Kubernetes Deployment.
* Kubernetes Service типу LoadBalancer.
* Kubernetes ConfigMap.
* Horizontal Pod Autoscaler.
* Metrics Server для роботи HPA.
* Публічний доступ до Django-застосунку.

## Структура проєкту

```text
lesson7/
├── app/
│   ├── config/
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── manage.py
│   └── requirements.txt
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── configmap.yaml
│       │   ├── deployment.yaml
│       │   ├── hpa.yaml
│       │   └── service.yaml
│       ├── Chart.yaml
│       └── values.yaml
│
├── modules/
│   ├── ecr/
│   │   ├── ecr.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── eks/
│   │   ├── eks.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   └── vpc/
│       ├── outputs.tf
│       ├── routes.tf
│       ├── variables.tf
│       └── vpc.tf
│
├── .gitignore
├── .terraform.lock.hcl
├── backend.tf
├── main.tf
├── outputs.tf
└── README.md
```

## Використані технології

* Terraform
* AWS VPC
* Amazon EKS
* Amazon ECR
* Docker
* Kubernetes
* Helm
* Django
* Gunicorn
* Metrics Server

## Terraform backend

Terraform state зберігається в Amazon S3.

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-vl-01"
    key          = "lesson-7/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Запуск Terraform

Ініціалізація:

```bash
terraform init
```

Форматування:

```bash
terraform fmt -recursive
```

Перевірка конфігурації:

```bash
terraform validate
```

Перегляд плану:

```bash
terraform plan
```

Створення інфраструктури:

```bash
terraform apply
```

Для підтвердження потрібно ввести:

```text
yes
```

## Terraform outputs

Після створення інфраструктури:

```bash
terraform output
```

Основні outputs:

```text
ecr_repository_url
eks_cluster_endpoint
eks_cluster_name
eks_node_group_name
public_subnet_ids
private_subnet_ids
vpc_id
```

## Підключення kubectl до EKS

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name lesson-7-eks
```

Перевірка worker nodes:

```bash
kubectl get nodes
```

## Збірка Docker-образу

Оскільки збірка виконується на Mac з Apple Silicon, образ для EKS потрібно збирати під платформу `linux/amd64`.

```bash
docker buildx build \
  --platform linux/amd64 \
  -t 058862856673.dkr.ecr.us-east-1.amazonaws.com/lesson-7-django:latest \
  --push \
  ./app
```

## Авторизація Docker в ECR

```bash
aws ecr get-login-password \
  --region us-east-1 \
| docker login \
  --username AWS \
  --password-stdin 058862856673.dkr.ecr.us-east-1.amazonaws.com
```

## Перевірка образу в ECR

```bash
aws ecr describe-images \
  --region us-east-1 \
  --repository-name lesson-7-django
```

## Встановлення Metrics Server

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
```

```bash
helm upgrade --install metrics-server \
  metrics-server/metrics-server \
  --namespace kube-system
```

Перевірка:

```bash
kubectl get pods -n kube-system | grep metrics-server
```

```bash
kubectl top nodes
```

## Перевірка Helm chart

```bash
helm lint charts/django-app
```

Генерація Kubernetes YAML без встановлення:

```bash
helm template django-app charts/django-app
```

## Встановлення Django через Helm

```bash
helm upgrade --install django-app charts/django-app
```

Перевірка ресурсів:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl get configmap
```

## Deployment

Deployment запускає Django-застосунок з Docker-образу, який знаходиться в Amazon ECR.

Змінні середовища підключаються через ConfigMap:

```yaml
envFrom:
  - configMapRef:
      name: django-app-config
```

## ConfigMap

ConfigMap містить:

```text
DJANGO_SECRET_KEY
DJANGO_DEBUG
DJANGO_ALLOWED_HOSTS
```

Перевірка:

```bash
kubectl get configmap django-app-config
```

## Service

Service має тип:

```yaml
type: LoadBalancer
```

AWS автоматично створює публічний Elastic Load Balancer.

Перевірка:

```bash
kubectl get svc django-app
```

## Horizontal Pod Autoscaler

HPA масштабує Django Deployment:

```text
мінімум: 2 pod-и
максимум: 6 pod-ів
CPU target: 70%
```

Перевірка:

```bash
kubectl get hpa
```

Приклад результату:

```text
NAME         REFERENCE               TARGETS      MINPODS   MAXPODS   REPLICAS
django-app   Deployment/django-app   cpu: 2%/70%  2         6         2
```

## Перевірка застосунку

Отримати адресу Load Balancer:

```bash
kubectl get svc django-app
```

Перевірити застосунок:

```bash
curl http://LOAD_BALANCER_ADDRESS
```

Очікувана відповідь:

```json
{
  "status": "ok",
  "message": "Django application is running in Kubernetes"
}
```

## Видалення Helm release

```bash
helm uninstall django-app
```

## Видалення Metrics Server

```bash
helm uninstall metrics-server -n kube-system
```

## Видалення AWS-інфраструктури

Після перевірки домашнього завдання інфраструктуру потрібно видалити, щоб уникнути витрат AWS:

```bash
terraform destroy
```

Для підтвердження потрібно ввести:

```text
yes
```

## Результат

У результаті виконання роботи:

* Kubernetes-кластер створений через Terraform.
* ECR створений через Terraform.
* Docker-образ Django завантажений у ECR.
* Django розгорнутий через Helm.
* ConfigMap підключений через `envFrom`.
* Service типу LoadBalancer доступний з інтернету.
* HPA масштабує Deployment від 2 до 6 pod-ів.
* Metrics Server надає CPU-метрики.
