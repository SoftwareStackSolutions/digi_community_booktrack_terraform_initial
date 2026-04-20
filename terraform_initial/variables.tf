# Variables
variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "github_org" {
  type        = string
  description = "GitHub Organization Name"
}

variable "repositories" {
  type        = list(string)
  description = "List of allowed GitHub repositories"
}

variable "role_name" {
  type        = string
  description = "IAM Role Name for GitHub Actions"
}