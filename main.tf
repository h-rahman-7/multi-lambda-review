module "lambda_shared" {
  source             = "./modules/lambda_shared"
  lambda_role_name   = var.lambda_role_name
  lambda_policy_name = var.lambda_policy_name
}

module "func1" {
  source          = "./modules/lambda_function"
  group_name      = var.group_name
  function_name   = "func1"
  s3_bucket       = var.lambda_s3_bucket
  s3_key          = "lambda-functions/${var.group_name}/func1.zip"
  handler         = "main.lambda_handler"
  runtime         = var.lambda_runtime
  lambda_role_arn = module.lambda_shared.lambda_role_arn
  
  environment_variables = {
    GREETING         = "Hello from Function 1"
    LAMBDA_S3_BUCKET = var.lambda_s3_bucket
  }

}

module "func2" {
  source          = "./modules/lambda_function"
  group_name      = var.group_name
  function_name   = "func2"
  s3_bucket       = var.lambda_s3_bucket
  s3_key          = "lambda-functions/${var.group_name}/func2.zip"
  handler         = "main.lambda_handler"
  runtime         = var.lambda_runtime
  lambda_role_arn = module.lambda_shared.lambda_role_arn
  environment_variables = {
    GREETING = "Hello from Function 2"
    LAMBDA_S3_BUCKET = var.lambda_s3_bucket
  }
}