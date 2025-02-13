# Create the Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.group_name}-${var.function_name}"
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  handler       = var.handler
  runtime       = var.runtime
  role          = var.lambda_role_arn
  
  environment {
    variables = var.environment_variables
  }
}
