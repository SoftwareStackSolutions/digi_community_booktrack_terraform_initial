# Output
output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}


output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "ecr_repository_urls" {
  value = {
    for repo_name, repo in aws_ecr_repository.repos :
    repo_name => repo.repository_url
  }
}

output "ecr_repository_names" {
  value = {
    for repo_name, repo in aws_ecr_repository.repos :
    repo_name => repo.name
  }
}