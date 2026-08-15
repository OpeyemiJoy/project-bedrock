terraform {
  backend "s3" {
    bucket       = "project-bedrock-tfstate-513282885838"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
