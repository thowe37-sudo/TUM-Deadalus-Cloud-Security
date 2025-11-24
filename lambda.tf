#############################
# Web App Lambda
#############################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/webapp.py"
  output_path = "${path.module}/web_app_lambda.zip"
}

resource "aws_lambda_function" "web_lambda" {
  function_name = "${var.iam_role_name}_get_file_web_lambda"
  role          = data.aws_iam_role.web_lambda_exec_role.arn
  handler       = "webapp.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

#############################
# Tropical Vault Lambda
#############################

data "archive_file" "tropical_vault_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/tropical_vault.py"
  output_path = "${path.module}/tropical_vault_lambda.zip"
}

resource "aws_lambda_function" "tropical_vault_lambda" {
  function_name    = "${var.iam_role_name}_tropical_vault_lambda"
  role             = data.aws_iam_role.web_lambda_exec_role.arn
  handler          = "tropical_vault.lambda_handler" 
  runtime          = "python3.11"
  filename         = data.archive_file.tropical_vault_lambda_zip.output_path
  source_code_hash = data.archive_file.tropical_vault_lambda_zip.output_base64sha256
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.tropical_vault_bucket.id
    }
  }
}
