data "aws_caller_identity" "current" {}

data "aws_iam_role" "web_lambda_exec_role" {
  name = "${var.iam_role_name}-web_lambda_exec_role"
}

data "aws_iam_role" "pat_auth_lambda_exec_role" {
  name = "${var.iam_role_name}-pat-auth-lambda-execution-role"
}
