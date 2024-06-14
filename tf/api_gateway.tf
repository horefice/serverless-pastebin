resource "aws_api_gateway_rest_api" "paste" {
  name = "paste_api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.paste.id
  parent_id   = aws_api_gateway_rest_api.paste.root_resource_id
  path_part   = aws_api_gateway_rest_api.paste.name
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.paste.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.paste.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.paste.invoke_arn
}

resource "aws_api_gateway_deployment" "paste" {
  rest_api_id = aws_api_gateway_rest_api.paste.id

  depends_on = [aws_api_gateway_integration.lambda]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "paste" {
  deployment_id = aws_api_gateway_deployment.paste.id
  rest_api_id   = aws_api_gateway_rest_api.paste.id
  stage_name    = "default"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.paste.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.paste.execution_arn}/*/*"
}

variable "throttling_burst_limit" {
  type        = number
  description = "maximum number of concurrent executions of the function. Default is 2."
  default     = 2
}

variable "throttling_rate_limit" {
  type        = number
  description = "maximum number of executions per second. Default is 2."
  default     = 2
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.paste.id
  stage_name  = aws_api_gateway_stage.paste.stage_name
  method_path = "*/*"

  settings {
    logging_level          = "ERROR"
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}

data "aws_iam_policy_document" "apigw_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "apigw_cloudwatch" {
  name               = "apigw_cloudwatch_role"
  assume_role_policy = data.aws_iam_policy_document.apigw_policy_document.json
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch_policy_attachment" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

output "base_url" {
  value = aws_api_gateway_deployment.paste.invoke_url
}