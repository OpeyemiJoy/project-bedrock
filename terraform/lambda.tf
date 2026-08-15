data "archive_file" "asset_processor" {
  type        = "zip"
  source_file = "${path.module}/lambda/asset_processor.py"
  output_path = "${path.module}/lambda/asset_processor.zip"
}

resource "aws_iam_role" "lambda_asset_processor" {
  name = "${local.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_asset_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_read" {
  name = "${local.lambda_function_name}-s3-read"

  role = aws_iam_role.lambda_asset_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "asset_processor" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_asset_processor.arn

  filename         = data.archive_file.asset_processor.output_path
  source_code_hash = data.archive_file.asset_processor.output_base64sha256

  handler = "asset_processor.lambda_handler"
  runtime = "python3.12"

  timeout     = 30
  memory_size = 128

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
