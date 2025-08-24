#!/usr/bin/env bash
set -euo pipefail

set -o allexport
source .env
set +o allexport

FUNC="stop_ec2_instance_o6H4BkLkb08Y"
REGION="eu-north-1"

aws lambda invoke \
  --function-name "$FUNC" \
  --payload "{\"instance_id\":\"$EC2_INSTANCE_ID\"}" \
  --cli-binary-format raw-in-base64-out \
  --region "$REGION" \
  --log-type Tail \
  out.json \
  --query 'LogResult' --output text | base64 --decode; echo

echo "Lambda response payload:"
cat out.json; echo