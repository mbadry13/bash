#!/bin/bash
## Bash Script to test the url from the load balancer end ##
URL="http://ocp4.homelab.mannai.local"
REQUESTS=200
DURATION=300
INTERVAL=$((DURATION / REQUESTS))

echo "Sending $REQUESTS requests to $URL over $DURATION seconds"

for ((i=1; i<=REQUESTS; i++)); do
  echo "Request $i..."
  curl -s -o /dev/null -w "%{http_code}\n" "$URL"
  sleep "$INTERVAL"
done

echo "Completed $REQUESTS requests."
