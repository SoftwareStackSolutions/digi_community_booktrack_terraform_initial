provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# Random ID (for unique bucket name)
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# Locals
# -----------------------------
locals {
  name_prefix = "${var.project}-${var.environment}-${random_id.suffix.hex}"

  repo_condition = [
    for repo in var.repositories :
    "repo:${var.github_org}/${repo}:*"
  ]

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

# -----------------------------
# OIDC Provider
# -----------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# -----------------------------
# IAM Role for GitHub Actions
# -----------------------------
resource "aws_iam_role" "github_actions" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.repo_condition
          }
        }
      }
    ]
  })
}

# -----------------------------
# Attach Policies
# -----------------------------
resource "aws_iam_role_policy_attachment" "attach" {
  for_each = toset(local.policy_arns)

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}

# -----------------------------
# S3 Bucket for Terraform State
# -----------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket = "${local.name_prefix}-tf-state"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Enable Versioning (optional)
resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Rule (cleanup old versions)
resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# -----------------------------
# DynamoDB Table for Locking
# -----------------------------
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${local.name_prefix}-tf-lock"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "null_resource" "clone_repos" {
  provisioner "local-exec" {
    command = "bash clone_all_repos.sh ${var.github_username} ${var.student_github_org}"
  }

  triggers = {
    always_run = timestamp()
  }
}