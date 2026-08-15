data "aws_iam_policy_document" "carts_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:retail-app:carts"]
    }
  }
}

resource "aws_iam_role" "carts" {
  name               = "project-bedrock-carts-role"
  assume_role_policy = data.aws_iam_policy_document.carts_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "carts_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]

    resources = [
      aws_dynamodb_table.carts.arn,
      "${aws_dynamodb_table.carts.arn}/index/*"
    ]
  }
}

resource "aws_iam_role_policy" "carts_dynamodb" {
  name   = "project-bedrock-carts-dynamodb"
  role   = aws_iam_role.carts.id
  policy = data.aws_iam_policy_document.carts_dynamodb.json
}
