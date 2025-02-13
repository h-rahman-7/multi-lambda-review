output "lambda_arn" {
  description = "ARN of the deployed Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}
