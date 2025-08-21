variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
  default     = "stop_ec2_instance_o6H4BkLkb08Y"
}

variable "lambda_function_handler" {
  type        = string
  description = "The handler of the Lambda function"
  default     = "lambda_function_stop_ec2_instance.lambda_handler"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy the Lambda function"
  default     = "eu-north-1"
}

variable "lambda_function_zip_name" {
  type        = string
  description = "The path to the Lambda function zip file"
  default     = "lambda_function_stop_ec2_instance.zip"
}

variable "instance_id" {
  type        = string
  description = "The ID of the EC2 instance to stop"
}

variable "artifacts_dir" {
  type        = string
  description = "The artifacts directory"
}
