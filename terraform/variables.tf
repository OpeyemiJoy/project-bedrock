variable "aws_region" {
  description = "AWS region for Project Bedrock"
  type        = string
  default     = "us-east-1"
}

variable "student_id" {
  description = "Tinyuka student ID used for unique resource naming"
  type        = string
  default     = "ALT/SOE/TIN/025/0005"
}

variable "s3_bucket_suffix" {
  description = "S3-compatible normalized student ID"
  type        = string
  default     = "alt-soe-tin-025-0005"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "vpc_name" {
  description = "VPC Name tag"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "namespace" {
  description = "Kubernetes application namespace"
  type        = string
  default     = "retail-app"
}

variable "project_tag" {
  description = "Required project tag"
  type        = string
  default     = "tinyuka-2025-capstone"
}

variable "eks_kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}
