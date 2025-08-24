variable "aws_region" {
    type        = string
    description = "The AWS region to deploy the Lambda function"
}

variable "lambda_function_name" {
    type        = string
    description = "The AWS lambda function name"
    default     = "upload_recent_songs_to_s3"
}

variable "lambda_function_handler" {
    type        = string
    description = "The handler of the Lambda function"
    default     = "lambda_function_upload_recent_songs_to_s3.lambda_handler"
}

variable "lambda_function_zip_name" {
    type        = string
    description = "The AWS lambda function zip name"
    default     = "lambda_function_upload_recent_songs_to_s3.zip"
}

variable "artifacts_dir" {
    type        = string
    description = "The artifacts directory"
}

variable "client_id" {
    type = string
    description = "The client id"
    sensitive = true 
}

variable "client_secret" {
    type = string
    description = "The client secret"
    sensitive = true
}

variable "redirect_uri" {
    type = string
    description = "The redirect uri"
    sensitive = true
}
variable "spotify_refresh_token"{
    type = string
    description = "The spotify refresh token"
    sensitive = true
}

variable "output_bucket_name" {
    type = string
    description = "The output bucket"
}

variable "output_prefix" {
    type = string
    description = "The output prefix"
}