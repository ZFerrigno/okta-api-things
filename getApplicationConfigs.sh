#!/bin/bash

# okta api token
OKTA_API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
OKTA_ORG="orgName"
OUTPUT_FILE="applications_details.json"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
MAG='\033[0;35m'
RED='\033[0;31m'

# fetch the list of all application IDs
app_ids=$(curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[].id')

echo "${MAG}Fetching application details...${NC}"
# loop through each app ID and fetch details
for id in $app_ids; do
    echo "${GREEN}Getting configs for Application ID $id .${NC}"
    curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps/$id" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.' >> "$OUTPUT_FILE"
done

echo "${CYAN}Finished. Check $OUTPUT_FILE${NC}"

