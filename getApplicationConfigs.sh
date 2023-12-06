#!/bin/bash

# Set your Okta API token
OKTA_API_TOKEN=$(security find-generic-password -a "entry" -s "okta-api" -w)
OKTA_ORG="org"
OUTPUT_FILE="applications_details.json"

# Fetch the list of all application IDs
app_ids=$(curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[].id')

echo "Fetching application details..."
# Loop through each app ID and fetch details
for id in $app_ids; do
    echo "Fetching details for App ID: $id"
    curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps/$id" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.' >> "$OUTPUT_FILE"
done

echo "Details fetched successfully and saved to $OUTPUT_FILE"

