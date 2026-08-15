locals {
  project_name = "project-bedrock"

  common_tags = {
    Project = var.project_tag
  }

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  assets_bucket_name = "bedrock-assets-${var.s3_bucket_suffix}"

  lambda_function_name = "bedrock-asset-processor"

  developer_user_name = "bedrock-dev-view"
}
