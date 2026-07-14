# Final DevOps Project

Фінальний DevOps-проєкт демонструє повний цикл створення, розгортання та моніторингу Django-застосунку в AWS.

Інфраструктура створюється за допомогою Terraform та включає:

* AWS VPC;
* public і private subnet-и у трьох Availability Zones;
* Internet Gateway і NAT Gateway;
* Amazon EKS;
* Amazon ECR;
* Amazon RDS PostgreSQL;
* Jenkins;
* Argo CD;
* Prometheus;
* Grafana;
* Metrics Server;
* Kubernetes Horizontal Pod Autoscaler;
* Helm chart для Django-застосунку.

## Архітектура

Проєкт використовує таку схему:

```text
Developer
    |
    v
GitHub repository
    |
    v
Jenkins Pipeline
    |
    +--> Build Docker image with Kaniko
    |
    +--> Push image to Amazon ECR
    |
    +--> Update image.tag in Helm values.yaml
    |
    +--> Push changes to GitHub
                       |
                       v
                    Argo CD
                       |
                       v
                  Amazon EKS
                       |
          +------------+-------------+
          |                          |
          v                          v
    Django application         Monitoring stack
          |                    Prometheus + Grafana
          v
    Amazon RDS PostgreSQL
```

## Основні компоненти

### VPC

Terraform створює окрему VPC із CIDR:

```text
10.0.0.0/16
```

Public subnet-и:

```text
10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
```

Private subnet-и:

```text
10.0.4.0/24
10.0.5.0/24
10.0.6.0/24
```

Availability Zones:

```text
us-east-1a
us-east-1b
us-east-1c
```

Public subnet-и мають маршрут через Internet Gateway.

Private subnet-и мають доступ до інтернету через NAT Gateway.

EKS worker nodes і RDS розміщуються у private subnet-ах.

### Amazon EKS

EKS використовується для запуску:

* Django-застосунку;
* Jenkins;
* Argo CD;
* Prometheus;
* Grafana;
* Metrics Server.

Node group:

```text
Instance type: t3.small
Desired size: 4
Minimum size: 3
Maximum size: 5
```

Для worker nodes підключені IAM policies:

* `AmazonEKSWorkerNodePolicy`;
* `AmazonEKS_CNI_Policy`;
* `AmazonEC2ContainerRegistryPullOnly`.

### Amazon ECR

Docker-образ Django зберігається в Amazon ECR:

```text
058862856673.dkr.ecr.us-east-1.amazonaws.com/final-project-django
```

Jenkins використовує Kaniko для збірки образу без Docker daemon.

### Amazon RDS

Проєкт створює PostgreSQL RDS instance у private subnet-ах.

Параметри:

```text
Engine: PostgreSQL
Database: appdb
Username: dbadmin
Port: 5432
Public access: disabled
Storage encryption: enabled
```

Поточний endpoint:

```text
final-project-rds.c6d6sq4gsqjo.us-east-1.rds.amazonaws.com
```

RDS Security Group дозволяє підключення до PostgreSQL лише з мережі VPC:

```text
10.0.0.0/16
```

Модуль RDS також підтримує Aurora через змінну:

```hcl
use_aurora = true
```

Для звичайної RDS:

```hcl
use_aurora = false
```

### Jenkins

Jenkins встановлюється через Helm за допомогою Terraform.

Jenkins працює в namespace:

```text
jenkins
```

Kubernetes Agent містить контейнери:

* `jnlp`;
* `kaniko`;
* `git`.

Kaniko використовується для:

* збірки Docker image;
* push image до Amazon ECR.

Git-контейнер використовується для:

* зміни `charts/django-app/values.yaml`;
* створення Git commit;
* push змін до GitHub.

Jenkins credentials не зберігаються у Git.

### Argo CD

Argo CD встановлюється через Helm за допомогою Terraform.

Argo CD стежить за:

```text
Repository:
https://github.com/lekar89/lesson7.git

Branch:
final_project

Path:
charts/django-app
```

Argo CD Application має автоматичну синхронізацію:

```yaml
automated:
  prune: true
  selfHeal: true
```

Поточний стан Application:

```text
Sync Status: Synced
Health Status: Healthy
```

### Prometheus і Grafana

Monitoring stack встановлюється через Helm chart:

```text
kube-prometheus-stack
```

До складу входять:

* Prometheus;
* Grafana;
* Alertmanager;
* kube-state-metrics;
* node exporter;
* Prometheus Operator;
* ServiceMonitor resources.

Prometheus збирає метрики Kubernetes-кластера, worker nodes і системних компонентів.

Grafana використовується для перегляду dashboard-ів і метрик.

### Metrics Server і HPA

Metrics Server встановлюється через Helm і керується Terraform.

Metrics Server надає Metrics API для:

```bash
kubectl top nodes
kubectl top pods
```

Django Deployment має CPU requests:

```yaml
resources:
  requests:
    cpu: 50m
    memory: 64Mi
```

HPA налаштований так:

```text
Minimum replicas: 2
Maximum replicas: 6
Target CPU: 70%
```

Приклад робочого HPA:

```text
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS
django-app   Deployment/django-app   cpu: 2%/70%   2         6         2
```

## Структура проєкту

```text
Project/
├── main.tf
├── backend.tf
├── variables.tf
├── outputs.tf
├── Jenkinsfile
├── README.md
├── .gitignore
│
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
│
├── modules/
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ecr/
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/
│   │   ├── eks.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/
│   │   ├── rds.tf
│   │   ├── aurora.tf
│   │   ├── shared.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── jenkins/
│   │   ├── jenkins.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── values.yaml
│   │
│   ├── argo_cd/
│   │   ├── argo_cd.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── values.yaml
│   │   └── charts/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── application.yaml
│   │           └── repository.yaml
│   │
│   └── monitoring/
│       ├── monitoring.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── values.yaml
│
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            ├── secret.yaml
            └── hpa.yaml
```

## Передумови

Для запуску потрібні:

* AWS account;
* AWS CLI;
* Terraform;
* kubectl;
* Helm;
* Docker Desktop;
* Git.

Перевірка встановлених інструментів:

```bash
aws --version
terraform version
kubectl version --client
helm version
docker --version
git --version
```

## AWS authentication

Налаштувати AWS CLI:

```bash
aws configure
```

Перевірити поточного користувача:

```bash
aws sts get-caller-identity
```

## Terraform variables

Секретні значення передаються через локальний файл:

```text
terraform.tfvars
```

Приклад:

```hcl
database_password = "CHANGE_ME"

jenkins_admin_user     = "admin"
jenkins_admin_password = "CHANGE_ME"

github_repository_url = "https://github.com/lekar89/lesson7.git"
github_branch         = "final_project"

grafana_admin_user     = "admin"
grafana_admin_password = "CHANGE_ME"
```

Файл `terraform.tfvars` не повинен потрапляти в Git.

У `.gitignore` додано:

```gitignore
terraform.tfvars
*.auto.tfvars
*.tfstate
*.tfstate.*
.terraform/
.DS_Store
```

## Bootstrap S3 backend

Terraform state зберігається в S3.

Backend використовує:

```text
S3 bucket:
terraform-state-bucket-vl-01

State key:
final-project/terraform.tfstate

DynamoDB table:
terraform-locks
```

Під час першого запуску S3 bucket ще не існує, тому backend треба створити окремо.

Рекомендований порядок:

1. Тимчасово використовувати local backend.
2. Створити S3 bucket і DynamoDB:

```bash
terraform init
terraform apply -target=module.s3_backend
```

3. Додати або розкоментувати S3 backend у `backend.tf`.
4. Перенести state:

```bash
terraform init -migrate-state
```

## Ініціалізація Terraform

```bash
terraform init
```

Після зміни backend:

```bash
terraform init -reconfigure
```

## Форматування та валідація

```bash
terraform fmt -recursive
terraform validate
```

Очікуваний результат:

```text
Success! The configuration is valid.
```

## Terraform plan

```bash
terraform plan
```

Після повного розгортання очікується:

```text
No changes. Your infrastructure matches the configuration.
```

## Розгортання інфраструктури

```bash
terraform apply
```

Підтвердити:

```text
yes
```

Terraform створює:

* VPC;
* public/private subnet-и;
* Internet Gateway;
* NAT Gateway;
* EKS;
* worker node group;
* ECR;
* RDS;
* Jenkins;
* Argo CD;
* Metrics Server;
* Prometheus;
* Grafana.

## Terraform outputs

```bash
terraform output
```

Основні outputs:

```text
eks_cluster_name
eks_cluster_endpoint
ecr_repository_url
database_endpoint
database_name
jenkins_service_name
argocd_application_name
grafana_service_name
prometheus_service_name
nat_gateway_public_ip
```

## Підключення до EKS

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name final-project-eks
```

Перевірка:

```bash
kubectl get nodes
```

Очікується чотири worker nodes у статусі:

```text
Ready
```

## Збірка та push Django image

Авторизація в ECR:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login \
    --username AWS \
    --password-stdin \
    058862856673.dkr.ecr.us-east-1.amazonaws.com
```

Для Mac з Apple Silicon образ збирається під `linux/amd64`:

```bash
docker buildx build \
  --platform linux/amd64 \
  -t 058862856673.dkr.ecr.us-east-1.amazonaws.com/final-project-django:latest \
  --push \
  ./app
```

Перевірка ECR:

```bash
aws ecr list-images \
  --region us-east-1 \
  --repository-name final-project-django
```

## Перевірка Django

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

Очікується:

```text
2 Django pods у статусі Running
LoadBalancer із зовнішнім DNS
HPA із реальним CPU percentage
```

Перевірка HTTP endpoint:

```bash
curl http://EXTERNAL_LOAD_BALANCER_ADDRESS
```

Приклад відповіді:

```json
{
  "status": "ok",
  "message": "Django application is running in Kubernetes"
}
```

## Перевірка Jenkins

```bash
kubectl get all -n jenkins
```

Port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Відкрити:

```text
http://localhost:8080
```

Jenkins administrator username:

```text
admin
```

Пароль задається через:

```hcl
jenkins_admin_password
```

## Перевірка Argo CD

```bash
kubectl get all -n argocd
```

Port-forward:

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Відкрити:

```text
https://localhost:8081
```

Перевірка Application:

```bash
kubectl get applications -n argocd
```

Очікуваний результат:

```text
NAME         SYNC STATUS   HEALTH STATUS
django-app   Synced        Healthy
```

Детальна інформація:

```bash
kubectl describe application django-app -n argocd
```

## Перевірка monitoring

```bash
kubectl get all -n monitoring
```

Перевірка Prometheus:

```bash
kubectl get prometheus -n monitoring
kubectl get servicemonitors -n monitoring
```

Port-forward Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Відкрити:

```text
http://localhost:3000
```

Grafana username:

```text
admin
```

Пароль задається через:

```hcl
grafana_admin_password
```

Port-forward Prometheus:

```bash
kubectl port-forward \
  svc/monitoring-kube-prometheus-prometheus \
  9090:9090 \
  -n monitoring
```

Відкрити:

```text
http://localhost:9090
```

## Перевірка Metrics Server

```bash
kubectl get deployment metrics-server -n kube-system
kubectl get apiservice v1beta1.metrics.k8s.io
```

Metrics API повинен мати:

```text
AVAILABLE: True
```

Перевірка метрик:

```bash
kubectl top nodes
kubectl top pods
```

## Перевірка HPA

```bash
kubectl get hpa
```

Приклад:

```text
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS
django-app   Deployment/django-app   cpu: 2%/70%   2         6         2
```

Значення не повинно бути:

```text
<unknown>
```

## Helm validation

Перевірка Django chart:

```bash
helm lint charts/django-app
```

Перевірка Argo CD applications chart:

```bash
helm lint modules/argo_cd/charts
```

Рендеринг Django chart:

```bash
helm template django-app charts/django-app
```

Dry-run:

```bash
helm template django-app charts/django-app \
  | kubectl apply --dry-run=client -f -
```

## CI/CD pipeline

Pipeline описаний у:

```text
Jenkinsfile
```

Основні stages:

1. `Checkout`
2. `Configure ECR authentication`
3. `Build and push image`
4. `Update Helm image tag`
5. `Commit and push Helm change`

Загальний процес:

```text
Git commit
    |
    v
Jenkins checkout
    |
    v
Kaniko build
    |
    v
Push image to ECR
    |
    v
Update Helm image.tag
    |
    v
Git push
    |
    v
Argo CD detects changes
    |
    v
Automatic Kubernetes deployment
```

У `charts/django-app/values.yaml` Jenkins оновлює:

```yaml
image:
  repository: 058862856673.dkr.ecr.us-east-1.amazonaws.com/final-project-django
  tag: latest
```

## Kubernetes ConfigMap і Secret

Несекретні змінні зберігаються в ConfigMap:

```text
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_USER
POSTGRES_DB
DJANGO_DEBUG
DJANGO_ALLOWED_HOSTS
```

Секретні значення зберігаються в Kubernetes Secret:

```text
POSTGRES_PASSWORD
DJANGO_SECRET_KEY
```

Реальні production secrets не повинні зберігатися у Git.

Для production рекомендовано використовувати:

* AWS Secrets Manager;
* External Secrets Operator;
* Sealed Secrets;
* HashiCorp Vault.

## Безпека

У проєкті реалізовано:

* EKS worker nodes у private subnet-ах;
* RDS у private subnet-ах;
* RDS без public access;
* Security Group для PostgreSQL;
* окремі IAM roles для EKS cluster і worker nodes;
* ECR pull policy для worker nodes;
* S3 encryption;
* S3 versioning;
* S3 public access block;
* Terraform state locking;
* sensitive Terraform variables;
* Kubernetes Secret для паролів;
* паролі виключені з Git через `.gitignore`.

## Перевірка фінального стану

```bash
terraform fmt -recursive
terraform validate
terraform plan

helm lint charts/django-app
helm lint modules/argo_cd/charts

kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get hpa

kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring

kubectl get applications -n argocd
kubectl get prometheus -n monitoring
kubectl get servicemonitors -n monitoring

kubectl top nodes
kubectl top pods
```

## Видалення інфраструктури

AWS-ресурси можуть створювати витрати.

Після перевірки проєкту інфраструктуру потрібно видалити:

```bash
terraform destroy
```

Підтвердити:

```text
yes
```

Важливо: S3 bucket і DynamoDB використовуються для Terraform state.

Необхідно враховувати порядок видалення:

1. Видалити основну інфраструктуру.
2. Переконатися, що state більше не потрібний.
3. За потреби зберегти резервну копію state.
4. Видалити S3 backend і DynamoDB окремо.

## Поточний результат

Під час фінальної перевірки підтверджено:

```text
Terraform validate: successful
Terraform plan: No changes
EKS nodes: 4 Ready
Django pods: 2 Running
Argo CD: Synced / Healthy
Jenkins: Running
Prometheus: Ready
Grafana: Running
Metrics API: Available
HPA: cpu 2% / 70%
LoadBalancer: available
```

## Repository

GitHub repository:

```text
https://github.com/lekar89/lesson7
```

Final project branch:

```text
final_project
```

Direct link:

```text
https://github.com/lekar89/lesson7/tree/final_project
```


