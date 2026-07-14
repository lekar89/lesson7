terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "terraform-state-bucket-vl-01"
    key          = "final-project/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}