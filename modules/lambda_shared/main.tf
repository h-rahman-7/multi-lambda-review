# resource "aws_iam_role" "lambda_role" {
#   name = var.lambda_role_name
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action    = "sts:AssumeRole",
#       Effect    = "Allow",
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name = var.lambda_policy_name
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       Effect   = "Allow",
#       Resource = "arn:aws:logs:*:*:*"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

# output "lambda_role_arn" {
#   value = aws_iam_role.lambda_role.arn
# }

#Existing IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


# Existing Policy for CloudWatch Logs
resource "aws_iam_policy" "lambda_policy" {
  name = var.lambda_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow",
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Inline Policy: Allow Lambda to upload translated PDFs to S3
resource "aws_iam_role_policy" "allow_s3_put_object" {
  name = "AllowS3PutObjectForTranslatedDocs"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "s3:PutObject",
      Resource = "arn:aws:s3:::translated-docs-nasim-eu/*"
    }]
  })
}

# Inline Policy: Allow Lambda to use AWS Translate (TranslateText)
resource "aws_iam_role_policy" "allow_translate_text" {
  name = "AllowTranslateText"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "translate:TranslateText",
      Resource = "*"  # Adjust resource restrictions if needed
    }]
  })
}

# Inline Policy: Allow Lambda to read from S3 (if required)
resource "aws_iam_role_policy" "lambda_s3_read_policy" {
  name = "LambdaS3ReadPolicy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
         "s3:GetObject",
         "s3:ListBucket"
      ],
      
      Resource = [
         "arn:aws:s3:::translated-docs-nasim-eu",
         "arn:aws:s3:::translated-docs-nasim-eu/*"
      ]
    }]
  })
}

# Attach the AWS Managed Basic Execution Role Policy (if not already managed)
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Output the Lambda Role ARN for reference
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
