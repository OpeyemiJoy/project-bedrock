data "aws_iam_policy_document" "cloudwatch_observability_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_observability" {
  name               = "project-bedrock-cloudwatch-observability"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_observability_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability" {
  role       = aws_iam_role.cloudwatch_observability.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = module.eks.cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [
    aws_eks_pod_identity_association.cloudwatch_observability
  ]
}
