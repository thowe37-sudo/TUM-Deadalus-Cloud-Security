# API Gateway
# Defines the core HTTP API and its public stage.
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.iam_role_name}_webapp_api"
  protocol_type = "HTTP"
  tags = {
    iam_role_name = var.iam_role_name
  }
}
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true
  tags = {
    iam_role_name = var.iam_role_name
  }
   access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
        "requestId"          = "$context.requestId",
        "ip"                 = "$context.identity.sourceIp",
        "requestTime"        = "$context.requestTime",
        "httpMethod"         = "$context.httpMethod",
        "routeKey"           = "$context.routeKey",
        "status"             = "$context.status",
        "protocol"           = "$context.protocol",
        "responseLength"     = "$context.responseLength",
        "integrationError"   = "$context.integration.error",
        "authorizerError"    = "$context.authorizer.error"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/api-gateway/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 7
  depends_on = [aws_apigatewayv2_api.http_api]
}


#############################
# Web App Integration
#############################

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.web_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "api_gateway_invoke-web_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /fruit"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"

  depends_on = [
    aws_apigatewayv2_integration.lambda_integration
  ]
}

#############################
# Tropical Vault Integration
#############################

resource "aws_apigatewayv2_integration" "tropical_vault_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.tropical_vault_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "vault_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /vault"
  target             = "integrations/${aws_apigatewayv2_integration.tropical_vault_integration.id}"
  authorization_type = "NONE" 
  
  depends_on = [
      aws_apigatewayv2_integration.tropical_vault_integration # Implicit dependency for route
  ]
}

resource "aws_lambda_permission" "api_gateway_invoke_tropical_vault_lambda" {
  statement_id  = "AllowAPIGatewayInvokeFiles"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tropical_vault_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


