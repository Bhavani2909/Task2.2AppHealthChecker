#!/usr/bin/env bash
# simple-healthcheck.sh - minimal app health checker
URL="${1:-http://localhost:8080}"   # default if no arg provided

# get HTTP code (follow redirects)
HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -L --max-time 5 "$URL")
CURL_EXIT=$?

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$CURL_EXIT" -ne 0 ] || [ -z "$HTTP_CODE" ]; then
  echo "$TIMESTAMP - $URL - DOWN (curl exit $CURL_EXIT)"
  exit 1
fi

# treat 2xx and 3xx as UP
if [[ "$HTTP_CODE" =~ ^[23] ]]; then
  echo "$TIMESTAMP - $URL - UP (HTTP $HTTP_CODE)"
  exit 0
else
  echo "$TIMESTAMP - $URL - DOWN (HTTP $HTTP_CODE)"
  exit 1
fi

