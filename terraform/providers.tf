provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "tinyuka-2025-capstone"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}
