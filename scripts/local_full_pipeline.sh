#!/usr/bin/env bash
set -euo pipefail

# Export everything read from .env
set -o allexport
source .env
set +o allexport

#----------------------------------------
# Cleanup function: stop instance + kill tunnel
#----------------------------------------
function cleanup {
  echo "$(date): Cleaning up…"
  
  if [[ -n "${TUNNEL_PID:-}" ]]; then
    echo "$(date): Killing SSH tunnel (PID $TUNNEL_PID)"
    kill "$TUNNEL_PID" || true
  fi

  echo "$(date): Stopping EC2 instance $EC2_INSTANCE_ID"
  aws ec2 stop-instances --instance-ids "$EC2_INSTANCE_ID"
}
trap cleanup EXIT

#----------------------------------------
# 1. Start EC2
#----------------------------------------
echo "$(date): Starting EC2 instance $EC2_INSTANCE_ID"
aws ec2 start-instances --instance-ids "$EC2_INSTANCE_ID"

echo "$(date): Waiting for instance to enter 'running' state…"
aws ec2 wait instance-running --instance-ids "$EC2_INSTANCE_ID"

#----------------------------------------
# 2. Wait for SSH on the instance
#----------------------------------------
until ssh -o BatchMode=yes \
          -o ConnectTimeout=5 \
          -o ExitOnForwardFailure=yes \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -i "$SSH_KEY_PATH" "$SSH_USER@$REMOTE_HOST" "echo SSH ok"; do
  echo "$(date): SSH check failed, retrying…" >&2
  sleep 5
done

#----------------------------------------
# 4. Run your pipeline (using forwarded port)
#----------------------------------------
echo "$(date): Updating database via tunnel on localhost:$LOCAL_PORT"
export DB_CONN_STRING="postgresql://user:pass@localhost:${LOCAL_PORT}/dbname"
python scripts/update_db.py

echo "$(date): Running dbt models"
dbt run

echo "$(date): Running ML playlist pipeline"
python scripts/ml/create_playlist_pipeline.py

# cleanup() trap will fire here