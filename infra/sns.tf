resource "aws_sns_topic" "paste_failure" {
  name = "paste_failure"
}

variable "email_address" {
  type        = string
  description = "email address to send failure notifications to"

  validation {
    condition     = can(regex("^[^@]+@[^@]+.[^@]+$", var.email_address))
    error_message = "value must be a valid email address"
  }
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.paste_failure.arn
  protocol  = "email"
  endpoint  = var.email_address
}

data "aws_iam_policy_document" "lambda_sns_policy_document" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.paste_failure.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name   = "lambda_sns_policy"
  policy = data.aws_iam_policy_document.lambda_sns_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

resource "aws_lambda_function_event_invoke_config" "lambda_event_invoke_config" {
  function_name = aws_lambda_function.paste.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.paste_failure.arn
    }
  }
}