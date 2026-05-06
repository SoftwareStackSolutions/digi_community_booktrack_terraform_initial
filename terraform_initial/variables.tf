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

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/stage/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
}

variable "github_username" {
  description = "Enter your GitHub username"
  type        = string
}

variable "student_github_org" {
  description = "Enter you target GitHub organization"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repositories" {
  default = [
    "auth-app",
    "order-app",
    "product-app",
    "tracking-app",
    "customer-ui",
    "admin-ui"
  ]
}
