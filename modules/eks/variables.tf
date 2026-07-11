variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the EKS cluster and worker nodes"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the EKS managed node group"
  type        = string
  default     = "lesson-7-nodes"
}

variable "instance_types" {
  description = "EC2 instance types used by worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Initial number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}