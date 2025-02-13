variable "group_name" {
  type        = string
  description = "The group name from the repo"
}

variable "function_name" {
  type        = string
  description = "The specific function name (derived from the folder name)"
}

variable "s3_bucket" {
  type        = string
  description = "The S3 bucket where the Lambda deployment package is stored"
}

variable "s3_key" {
  type        = string
  description = "The S3 key (path) for the deployment package zip"
}

variable "handler" {
  type        = string
  description = "Lambda function handler"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime environment"
}

variable "lambda_role_arn" {
  type        = string
  description = "The IAM role ARN for the Lambda function"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}
