provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_stop_ec2_exec_role_${var.lambda_function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_ec2_policy_${var.lambda_function_name}"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInstances",
          "ec2:StopInstances"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "stop_instance_lambda" {
  function_name = var.lambda_function_name

  role          = aws_iam_role.lambda_exec_role.arn
  handler       = var.lambda_function_handler
  runtime       = "python3.11"
  filename      = "${var.artifacts_dir}/${var.lambda_function_zip_name}"
  source_code_hash = filebase64sha256("${var.artifacts_dir}/${var.lambda_function_zip_name}")

  timeout = 10
}

resource "aws_cloudwatch_event_rule" "nightly_trigger" {
  name                = "${var.lambda_function_name}_nightly_rule"
  schedule_expression = "cron(0 0 * * ? *)"  # 00:00 UTC daily
  description         = "Triggers Lambda to stop EC2 instance every night"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.nightly_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.stop_instance_lambda.arn

  input = jsonencode({
    instance_id = var.instance_id
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instance_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nightly_trigger.arn
}
