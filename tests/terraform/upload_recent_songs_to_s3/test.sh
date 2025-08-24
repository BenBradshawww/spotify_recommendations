FUNC="upload_recent_songs_to_s3" 
REGION="eu-north-1"                  

aws lambda invoke \
  --function-name "$FUNC" \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  --region "$REGION" \
  --log-type Tail \
  out.json \
  --query 'LogResult' --output text | base64 --decode; echo

echo "Lambda response payload:"
cat out.json; echo