output "lambda_role_arn" {
  description = "IAM Role ARN for Lambda functions"
  value       = module.lambda_shared.lambda_role_arn
}

output "s3_bucket_name" {
  description = "S3 bucket used for Lambda deployments"
  value       = var.lambda_s3_bucket
}

output "function1_arn" {
  description = "ARN of Lambda Function 1"
  value       = module.func1.lambda_arn
}

output "function2_arn" {
  description = "ARN of Lambda Function 2"
  value       = module.func2.lambda_arn 
}
