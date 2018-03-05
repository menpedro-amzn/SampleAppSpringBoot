#!/bin/bash
set -e

FLOOD_API_TOKEN=$1
FLOOD_NAME=$2

# Check we have the jq binary to make parsing JSON responses a bit easier
command -v jq >/dev/null 2>&1 || \
{ echo >&2 "Please install http://stedolan.github.io/jq/download/  Aborting."; exit 1; }

# Start a flood
echo
echo "[$(date +%FT%T)+00:00] Starting flood"
flood_uuid=$(curl -u $FLOOD_API_TOKEN: -X POST https://api.flood.io/floods \
-F "flood[tool]=gatling" \
-F "flood[privacy]=public" \
-F "flood[name]=$FLOOD_NAME" \
-F "flood_files[]=@SampleAppSpringBootTest.scala" \
-F "flood[grids][][infrastructure]=demand" \
-F "flood[grids][][instance_quantity]=1" \
-F "flood[grids][][region]=us-east-1" \
-F "flood[grids][][instance_type]=m4.xlarge" \
-F "flood[grids][][stop_after]=15" | jq -r ".uuid")

# Wait for flood to finish
echo "[$(date +%FT%T)+00:00] Waiting for flood $flood_uuid"
while [ $(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | \
  jq -r '.status == "finished"') = "false" ]; do
  echo -n "."
  sleep 3
done

# Get the summary report
flood_report=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/report | \
  jq -r ".summary")

echo
echo "[$(date +%FT%T)+00:00] Detailed results at https://flood.io/$flood_uuid"
echo "$flood_report"

# Validate error rate
error_rate=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | jq -r .error_rate)
if [ "$error_rate" -gt "0" ]; then
  echo "Flood test failed with error rate $error_rate%"
  exit 1
fi
response_time=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | jq -r .response_time)
if [ "$response_time" -gt "1000" ]; then
  echo "Flood test failed with $response_time > 1000ms"
  exit 2
fi
