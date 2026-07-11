# Домашнє завдання «Jenkins + Argo CD + CI/CD»

У цьому проєкті реалізовано конфігурацію CI/CD-процесу для Django-застосунку з використанням Jenkins, Kaniko, Amazon ECR, Helm, Terraform та Argo CD.

## Реалізовано

* AWS VPC через Terraform.
* Amazon EKS через Terraform.
* Amazon ECR через Terraform.
* Django Docker image.
* Helm chart для Django.
* Jenkins через Helm та Terraform.
* Kubernetes Agent для Jenkins.
* Контейнери Kaniko та Git у Jenkins agent.
* Jenkins pipeline через `Jenkinsfile`.
* Збірка Docker image через Kaniko.
* Push Docker image в Amazon ECR.
* Оновлення image tag у `charts/django-app/values.yaml`.
* Push змін у GitHub-гілку `lesson-8-9`.
* Argo CD через Helm та Terraform.
* Argo CD Application для Django Helm chart.
* Автоматична синхронізація через `prune` і `selfHeal`.

## Структура проєкту

```text
lesson7/
├── app/
│   ├── config/
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
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   │   ├── jenkins.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   └── variables.tf
│   │
│   └── argo_cd/
│       ├── argo_cd.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── variables.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
├── Jenkinsfile
├── backend.tf
├── main.tf
├── outputs.tf
├── variables.tf
└── README.md
```

## Jenkins

Jenkins встановлюється через Terraform за допомогою Helm provider.

```hcl
module "jenkins" {
  source = "./modules/jenkins"
}
```

Jenkins працює у namespace:

```text
jenkins
```

Для Jenkins Agent використовуються контейнери:

```text
jnlp
kaniko
git
```

Kaniko дозволяє збирати Docker image без Docker daemon.

## Jenkins pipeline

Pipeline описаний у файлі:

```text
Jenkinsfile
```

Основні етапи:

1. Checkout Git-репозиторію.
2. Авторизація в Amazon ECR.
3. Збірка Docker image через Kaniko.
4. Push image у ECR.
5. Оновлення `image.tag` у Helm values.
6. Git commit.
7. Push змін у гілку `lesson-8-9`.

Для кожної збірки створюється тег:

```text
build-${BUILD_NUMBER}
```

Наприклад:

```text
build-1
build-2
build-3
```

## Amazon ECR

Docker image завантажується в:

```text
058862856673.dkr.ecr.us-east-1.amazonaws.com/lesson-7-django
```

Приклад image URI:

```text
058862856673.dkr.ecr.us-east-1.amazonaws.com/lesson-7-django:build-10
```

## Argo CD

Argo CD встановлюється через Terraform і Helm у namespace:

```text
argocd
```

Argo CD стежить за репозиторієм:

```text
https://github.com/lekar89/lesson7.git
```

Гілка:

```text
lesson-8-9
```

Шлях до Helm chart:

```text
charts/django-app
```

## Автоматична синхронізація

Argo CD Application використовує:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

`prune` видаляє ресурси, яких більше немає в Git.

`selfHeal` повертає Kubernetes-ресурси до стану, описаного в Git.

## Повний CI/CD процес

```text
Зміна коду
    ↓
GitHub
    ↓
Jenkins Pipeline
    ↓
Kaniko build
    ↓
Amazon ECR
    ↓
Оновлення values.yaml
    ↓
Git commit і push
    ↓
Argo CD
    ↓
Helm deployment
    ↓
Amazon EKS
```

## Terraform

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

План:

```bash
terraform plan
```

Застосування:

```bash
terraform apply
```

## Перевірка Helm chart

```bash
helm lint charts/django-app
```

```bash
helm lint modules/argo_cd/charts
```

## Перевірка Jenkins

```bash
kubectl get pods -n jenkins
```

```bash
kubectl get svc -n jenkins
```

## Перевірка Argo CD

```bash
kubectl get pods -n argocd
```

```bash
kubectl get svc -n argocd
```

```bash
kubectl get applications -n argocd
```

## Jenkins credentials

Для роботи pipeline в Jenkins потрібно створити credentials:

```text
aws-credentials
github-credentials
```

`aws-credentials` містить AWS Access Key ID та AWS Secret Access Key.

`github-credentials` містить GitHub username та Personal Access Token.

Секрети не повинні зберігатися у Git-репозиторії.

## GitHub

Робота знаходиться у гілці:

```text
lesson-8-9
```

Репозиторій:

```text
https://github.com/lekar89/lesson7
```

## Видалення інфраструктури

Після перевірки домашнього завдання:

```bash
terraform destroy
```

Це потрібно зробити, щоб уникнути подальших витрат AWS.
