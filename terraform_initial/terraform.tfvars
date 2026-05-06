aws_account_id = "088310115913"
github_org = "SoftwareStackSolutions"
repositories = [
  "digi_community_booktrack_genericicicd",
  "digi_community_booktrack_auth",
  "digi_community_booktrack_order",
  "digi_community_booktrack_product",
  "digi_community_booktrack_tracking",
  "digi_community_booktrack_customerui",
  "digi_community_booktrack_adminui",
  "digi_community_booktrack_infra",
  "digi_community_booktrack_artifact"
]

role_name = "github-actions-role"
project                 = "digidense"
environment             = "dev"
aws_region              = "us-east-1"
enable_versioning       = true
dynamodb_billing_mode   = "PAY_PER_REQUEST"
bucket_name             = "digi-dev-tf-s3-bucket"
dynamodb_table_name     = "digi-dev-tf-lock-state"
ecr_repository_name     = "digi-application-ecr"