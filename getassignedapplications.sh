#!/bin/bash

# Set your Okta API token
OKTA_API_TOKEN=$(security find-generic-password -a "" -s "okta-api" -w)
OKTA_ORG=""
output="userAppAssignments.txt"
app_details=$(curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[] | "\(.id) \(.label)"')

echo "Gathering the facts..."
# Loop through each app_id and fetch users, then append to output file
while read -r app_info; do
    app_id=$(echo "$app_info" | awk '{print $1}')
    app_label=$(echo "$app_info" | awk '{$1=""; print $0}')
    echo "Gathering member list for $app_label"
    echo "Application ID: $app_id - Label: $app_label" >> "$output"
    curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps/$app_id/users" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[].credentials.userName' >> "$output"
    echo "" >> "$output" # Add a newline for separation

done <<< "$app_details"
echo "Finished. Check $output"