#!/usr/bin/env bash
# healthcheck-retry.sh - app health checker with retries

URL="${1:-http://localhost:8080}"   # default if no arg provided
RETRIES=3                           # number of attempts
DELAY=2                             # seconds to wait between attempts
TIMEOUT=5                           # max seconds to wait per request

attempt=1
success=0
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

while [ $attempt -le $RETRIES ]; do
  echo "$TIMESTAMP - Checking $URL (attempt $attempt/$RETRIES)..."

  HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -L --max-time $TIMEOUT "$URL")
  CURL_EXIT=$?

  if [ "$CURL_EXIT" -ne 0 ] || [ -z "$HTTP_CODE" ]; then
    echo "$TIMESTAMP - $URL - DOWN (curl exit $CURL_EXIT)"
  elif [[ "$HTTP_CODE" =~ ^[23] ]]; then
    echo "$TIMESTAMP - $URL - UP (HTTP $HTTP_CODE)"
    success=1
    break
  else
    echo "$TIMESTAMP - $URL - DOWN (HTTP $HTTP_CODE)"
  fi

  attempt=$((attempt+1))
  sleep $DELAY
done

# final status
if [ $success -eq 1 ]; then
  exit 0
else
  exit 1
fi

