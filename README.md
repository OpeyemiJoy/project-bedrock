# Project Bedrock — Production-Grade Microservices on AWS EKS

## 1. Project Overview

Project Bedrock is InnovateMart Inc. production deployment of the AWS Retail Store Sample Application on Amazon EKS.

The project provisions AWS infrastructure using Terraform, deploys the application in the retail-app namespace, uses managed AWS database services, exposes the application through an Application Load Balancer, provides CloudWatch observability, and implements S3-to-Lambda asset processing.

## 2. AWS Environment

- AWS Region: us-east-1
- EKS Cluster: project-bedrock-cluster
- VPC: project-bedrock-vpc
- Application Namespace: retail-app
- Developer IAM User: bedrock-dev-view
- S3 Assets Bucket: bedrock-assets-alt-soe-tin-025-0005
- Lambda Function: bedrock-asset-processor
- Project Tag: Project: tinyuka-2025-capstone

## 3. Repository

GitHub repository:

git@github.com:OpeyemiJoy/project-bedrock.git

## 4. Architecture

The environment contains an AWS VPC, Amazon EKS, an Application Load Balancer, Amazon RDS, DynamoDB, CloudWatch, S3, and Lambda.

### Application Traffic

Internet
  |
  v
Application Load Balancer
  |
  v
AWS Load Balancer Controller
  |
  v
retail-store-ingress
  |
  v
UI Service
  |
  v
Retail Store Application
  |
  +--> Catalog --> Amazon RDS MySQL
  |
  +--> Orders --> Amazon RDS PostgreSQL
  |
  +--> Carts --> Amazon DynamoDB

### Serverless Asset Processing

Developer
  |
  | s3:PutObject
  v
Private S3 Assets Bucket
  |
  | ObjectCreated event
  v
Lambda: bedrock-asset-processor
  |
  v
CloudWatch Logs

## 5. Terraform Infrastructure

Terraform is used to provision and manage the AWS infrastructure.

Terraform state is stored remotely in Amazon S3 with encryption and native S3 state locking enabled.

The required Terraform outputs are:

- cluster_endpoint
- cluster_name
- region
- vpc_id
- assets_bucket_name

Grading data is generated with:

terraform -chdir=terraform output -json > grading.json

## 6. Application

The Retail Store Sample Application runs in the retail-app namespace.

Verify the application with:

kubectl get pods -n retail-app

kubectl get svc -n retail-app

## 7. Application Ingress

The AWS Load Balancer Controller manages the Application Load Balancer.

Ingress name:

retail-store-ingress

Application URL:

http://k8s-retailap-retailst-17d19cf248-847312976.us-east-1.elb.amazonaws.com

Verify with:

kubectl get ingress -n retail-app

## 8. Managed Data Layer

Catalog uses Amazon RDS for MySQL.

Orders uses Amazon RDS for PostgreSQL.

Carts uses Amazon DynamoDB.

The RDS databases run in private subnets and are not publicly accessible.

## 9. Developer Access

The developer IAM user is:

bedrock-dev-view

The user has AWS ReadOnlyAccess and an EKS Access Entry associated with AmazonEKSViewPolicy scoped to the retail-app namespace.

The user also has s3:PutObject permission restricted to the Project Bedrock assets bucket.

AWS credentials must never be committed to GitHub.

## 10. Observability

Amazon CloudWatch Observability is enabled through the EKS add-on.

The configuration includes:

- EKS Pod Identity Agent
- Amazon CloudWatch Observability add-on
- CloudWatch Agent permissions
- Pod Identity association

EKS control-plane and application/container logs are sent to CloudWatch.

## 11. Serverless Asset Processing

The private S3 bucket is:

bedrock-assets-alt-soe-tin-025-0005

The bucket has public access blocked, encryption enabled, and versioning enabled.

The Lambda function is:

bedrock-asset-processor

The Lambda function is triggered when an object is uploaded to the S3 bucket.

The Lambda function logs the uploaded filename to CloudWatch.

## 12. CI/CD

GitHub Actions automates Terraform infrastructure changes.

Pull requests run terraform plan and post the plan for review.

Merges to main run terraform apply.

AWS credentials are managed through GitHub Actions configuration and are not hardcoded in workflow files.

## 13. Cost Controls

An AWS Budget of 20 USD per month is configured for the Project Bedrock resources.

The VPC uses a single NAT Gateway to reduce costs.

## 14. Verification

Check the EKS cluster:

aws eks describe-cluster --name project-bedrock-cluster --region us-east-1

Check nodes:

kubectl get nodes

Check application:

kubectl get pods -n retail-app

Check ingress:

kubectl get ingress -n retail-app

Check Load Balancer Controller:

kubectl get pods -n kube-system | grep aws-load-balancer

Check Terraform:

terraform -chdir=terraform plan

## 15. Grading Data

The required grading output is stored in:

grading.json

It contains:

- cluster_endpoint
- cluster_name
- region
- vpc_id
- assets_bucket_name

No database passwords or IAM secrets are included as Terraform root outputs.

## 16. Teardown

When the assessment is complete, destroy the Terraform-managed environment:

terraform -chdir=terraform destroy

If the S3 bucket contains objects, empty the bucket first and rerun Terraform destroy.

After destruction, verify that no manually-created AWS resources remain.

## 17. Security

- AWS credentials are not committed to the repository.
- Database passwords are not committed to the repository.
- RDS databases are private.
- The S3 bucket is private.
- Developer Kubernetes access is limited to the retail-app namespace.
- Developer S3 upload permission is limited to the Project Bedrock assets bucket.

## 18. Project Status

The Project Bedrock core infrastructure, application deployment, managed data layer, ingress, developer access, observability, serverless processing, CI/CD automation, cost controls, grading output, and documentation have been implemented.
