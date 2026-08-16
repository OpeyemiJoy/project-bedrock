resource "aws_iam_user" "developer_view" {
  name = local.developer_user_name

  tags = local.common_tags
}

resource "aws_iam_user_policy_attachment" "developer_read_only" {
  user       = aws_iam_user.developer_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_eks_access_entry" "developer_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.developer_view.arn
  type          = "STANDARD"
}
resource "aws_eks_access_policy_association" "developer_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.developer_view.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["retail-app"]
  }
}
resource "aws_iam_user_policy" "developer_s3_upload" {
  name = "${local.developer_user_name}-s3-upload"
  user = aws_iam_user.developer_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}
