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
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_s3_full_${var.lambda_function_name}"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "upload_songs_lambda" {
  function_name     = var.lambda_function_name
  role              = aws_iam_role.lambda_exec_role.arn
  handler           = var.lambda_function_handler
  runtime           = "python3.11"
  filename          = "${var.artifacts_dir}/${var.lambda_function_zip_name}"
  source_code_hash  = filebase64sha256("${var.artifacts_dir}/${var.lambda_function_zip_name}")
  timeout           = 10

  environment {
    variables = {
      CLIENT_ID             = var.client_id
      CLIENT_SECRET         = var.client_secret
      REDIRECT_URI          = var.redirect_uri
      SPOTIFY_REFRESH_TOKEN = var.spotify_refresh_token
      OUTPUT_BUCKET_NAME    = var.output_bucket_name
      OUTPUT_PREFIX         = var.output_prefix
    }
  }
}

resource "aws_cloudwatch_event_rule" "hourly_trigger" {
  name                = "${var.lambda_function_name}_hourly_rule"
  description         = "Triggers Lambda every hour"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.hourly_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.upload_songs_lambda.arn

  depends_on = [aws_lambda_permission.allow_eventbridge]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_songs_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly_trigger.arn
}