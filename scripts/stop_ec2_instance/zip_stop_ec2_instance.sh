#!/usr/bin/env bash
set -euo pipefail

ART_DIR="artifacts"
PY_FILE="scripts/stop_ec2_instance/lambda_function_stop_ec2_instance.py"
ZIP_NAME="lambda_function_stop_ec2_instance.zip"

zip $ZIP_NAME $PY_FILE

cp $ZIP_NAME artifacts/

rm $ZIP_NAME

echo "Built $ART_DIR/$ZIP_NAME"