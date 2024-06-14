resource "aws_lambda_function" "paste" {
  function_name = "paste_lambda"
  # memory_size = 128

  filename = "lambda_function.zip"
  handler  = "lambda_function.lambda_handler"
  runtime  = "python3.12"

  environment {
    variables = {
      table                = aws_dynamodb_table.paste.name
      table_key_attribute  = aws_dynamodb_table.paste.hash_key
      table_data_attribute = "data"
      table_ttl_attribute  = aws_dynamodb_table.paste.ttl[0].attribute_name
      table_ttl_value      = 1209600
    }
  }

  role = aws_iam_role.lambda_exec.arn
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "paste_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "log_retention_in_days" {
  type        = number
  description = "number of days to retain log events in CloudWatch Logs. Default is 14."
  default     = 14
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.paste.function_name}"
  retention_in_days = var.log_retention_in_days
}