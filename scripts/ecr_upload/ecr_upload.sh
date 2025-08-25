#!/usr/bin/env bash
set -euo pipefail

set -o allexport
source .env
set +o allexport

AWS_REGION="${AWS_REGION:-eu-north-1}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
ECR_REPO_NAME="${ECR_REPO_NAME:-my-docker-repo}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Ensuring repo $ECR_REPO_NAME exists..."
aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" --region "$AWS_REGION" >logs/ecr_upload 2>&1 \
  || aws ecr create-repository --repository-name "$ECR_REPO_NAME" --region "$AWS_REGION"

echo "Building Docker image..."
docker build -t "$ECR_REPO_NAME:$IMAGE_TAG" .

echo "Tagging image for ECR..."
docker tag "$ECR_REPO_NAME:$IMAGE_TAG" "$ECR_URI"

echo "Pushing to ECR..."
docker push "$ECR_URI"

echo "Done! Image pushed to:"
echo "$ECR_URI"