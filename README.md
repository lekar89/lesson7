# Домашнє завдання: гнучкий Terraform-модуль для баз даних

У проєкті реалізовано універсальний Terraform-модуль `rds`, який залежно від змінної `use_aurora` створює:

* звичайну Amazon RDS instance з PostgreSQL або MySQL;
* або Amazon Aurora Cluster з Aurora PostgreSQL чи Aurora MySQL.

Модуль автоматично створює спільні мережеві ресурси та parameter groups.

## Реалізовано

* звичайна RDS instance через `aws_db_instance`;
* Aurora Cluster через `aws_rds_cluster`;
* Aurora writer instance через `aws_rds_cluster_instance`;
* умовне створення ресурсів через `use_aurora`;
* DB Subnet Group;
* Security Group;
* Parameter Group для звичайної RDS;
* Cluster Parameter Group для Aurora;
* підтримка PostgreSQL і MySQL;
* налаштування engine version;
* налаштування instance class;
* підтримка Multi-AZ для звичайної RDS;
* універсальні outputs.

## Структура модуля

```text
modules/rds/
├── aurora.tf
├── outputs.tf
├── rds.tf
├── shared.tf
└── variables.tf
```

### `shared.tf`

Створює спільні ресурси:

* `aws_db_subnet_group`;
* `aws_security_group`;
* `aws_db_parameter_group`;
* `aws_rds_cluster_parameter_group`.

### `rds.tf`

Створює звичайну RDS instance, якщо:

```hcl
use_aurora = false
```

### `aurora.tf`

Створює Aurora Cluster та cluster instances, якщо:

```hcl
use_aurora = true
```

## Приклад використання модуля

```hcl
module "rds" {
  source = "./modules/rds"

  project_name = "lesson-db-module"

  use_aurora = var.use_aurora

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [
    "10.0.0.0/16"
  ]

  engine         = var.database_engine
  engine_version = var.database_engine_version
  instance_class = var.database_instance_class

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.database_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  multi_az              = var.database_multi_az
  publicly_accessible   = false
  deletion_protection   = false
  skip_final_snapshot   = true
  aurora_instance_count = 1

  max_connections = "100"
  log_statement    = "none"
  work_mem         = "4096"

  tags = {
    Environment = "homework"
    Lesson      = "db-module"
  }
}
```

## Створення звичайної PostgreSQL RDS

```hcl
use_aurora              = false
database_engine         = "postgres"
database_engine_version = "16.4"
database_instance_class = "db.t3.micro"
database_multi_az       = false
database_password       = "CHANGE_ME"
```

У цьому режимі Terraform створює:

* одну `aws_db_instance`;
* DB Subnet Group;
* Security Group;
* PostgreSQL Parameter Group.

## Створення PostgreSQL Aurora

```hcl
use_aurora              = true
database_engine         = "postgres"
database_engine_version = "16.4"
database_instance_class = "db.t3.medium"
database_password       = "CHANGE_ME"
```

У цьому режимі Terraform створює:

* `aws_rds_cluster`;
* Aurora writer instance;
* DB Subnet Group;
* Security Group;
* Aurora Cluster Parameter Group.

Кількість Aurora instances задається через:

```hcl
aurora_instance_count = 1
```

Значення `1` створює один writer.

Значення `2` створює writer і додаткову reader instance.

## Створення звичайної MySQL RDS

```hcl
use_aurora              = false
database_engine         = "mysql"
database_engine_version = "8.0"
database_instance_class = "db.t3.micro"
database_multi_az       = false
database_password       = "CHANGE_ME"
```

## Створення Aurora MySQL

```hcl
use_aurora              = true
database_engine         = "mysql"
database_engine_version = "8.0"
database_instance_class = "db.t3.medium"
database_password       = "CHANGE_ME"
```

## Основні змінні

### `use_aurora`

Тип:

```hcl
bool
```

* `false` — звичайна RDS instance;
* `true` — Aurora Cluster.

### `engine`

Тип:

```hcl
string
```

Підтримувані значення:

```text
postgres
mysql
```

### `engine_version`

Версія database engine.

Приклади:

```text
16.4
8.0
```

### `instance_class`

Клас інстансу бази даних.

Приклади:

```text
db.t3.micro
db.t3.medium
```

### `multi_az`

Вмикає Multi-AZ для звичайної RDS instance.

```hcl
multi_az = true
```

Для Aurora ця змінна не використовується, оскільки Aurora працює як cluster.

### `vpc_id`

ID мережі, у якій створюється Security Group.

### `subnet_ids`

Список приватних subnet IDs для DB Subnet Group.

Приклад:

```hcl
subnet_ids = module.vpc.private_subnet_ids
```

### `allowed_cidr_blocks`

Список CIDR, яким дозволено підключення до бази.

Приклад:

```hcl
allowed_cidr_blocks = [
  "10.0.0.0/16"
]
```

### `database_name`

Назва початкової бази даних.

За замовчуванням:

```text
appdb
```

### `username`

Master username.

За замовчуванням:

```text
dbadmin
```

### `password`

Master password.

Змінна позначена як `sensitive` і не повинна зберігатися у Git.

### `allocated_storage`

Початковий storage звичайної RDS у GiB.

За замовчуванням:

```text
20
```

### `max_allocated_storage`

Максимальний storage при автоматичному масштабуванні.

За замовчуванням:

```text
100
```

### `aurora_instance_count`

Кількість інстансів усередині Aurora Cluster.

За замовчуванням:

```text
1
```

### `max_connections`

Значення параметра `max_connections`.

### `log_statement`

Параметр PostgreSQL для журналювання SQL-запитів.

### `work_mem`

Параметр PostgreSQL для пам’яті операцій сортування та обробки запитів.

## Parameter Groups

Для PostgreSQL використовуються параметри:

```text
max_connections
log_statement
work_mem
```

Для MySQL використовується:

```text
max_connections
```

Модуль автоматично вибирає правильний тип parameter group:

* `aws_db_parameter_group` для звичайної RDS;
* `aws_rds_cluster_parameter_group` для Aurora.

## Безпека

База за замовчуванням не доступна з інтернету:

```hcl
publicly_accessible = false
```

Storage шифрується:

```hcl
storage_encrypted = true
```

Доступ обмежений Security Group та значенням:

```hcl
allowed_cidr_blocks
```

## Outputs

Модуль повертає:

```text
database_type
endpoint
port
database_name
security_group_id
subnet_group_name
parameter_group_name
rds_instance_id
aurora_cluster_id
aurora_reader_endpoint
```

Універсальний endpoint можна отримати так:

```hcl
module.rds.endpoint
```

Він працює і для звичайної RDS, і для Aurora.

## Запуск Terraform

Ініціалізація:

```bash
terraform init
```

Форматування:

```bash
terraform fmt -recursive
```

Перевірка:

```bash
terraform validate
```

Перегляд плану:

```bash
terraform plan
```

Створення ресурсів:

```bash
terraform apply
```

Видалення ресурсів:

```bash
terraform destroy
```


