variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-2"
}

variable "group_name" {
  type        = string
  description = "The group name to be prefixed to Lambda names"
  default     = "lambda-deployment"
}

variable "lambda_role_name" {
  type        = string
  description = "IAM role name for Lambda"
  default     = "multi_lambda_role"
}

variable "lambda_policy_name" {
  type        = string
  description = "IAM policy name for Lambda"
  default     = "multi_lambda_policy"
}

variable "lambda_s3_bucket" {
  type        = string
  description = "S3 bucket where Lambda deployment zips are stored"
  default     = "translated-docs-nasim-eu"
  }

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.9"
}

variable "timeout" {
  description = "The Lambda function timeout (in seconds)"
  type        = number
  default     = 60  # Default value, can be overridden
}

variable "layers" {
  description = "List of Lambda layer ARNs"
  type        = list(string)
  default     = []  # Default empty list
}
