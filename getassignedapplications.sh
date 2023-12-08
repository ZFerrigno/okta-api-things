#!/bin/bash

# set api token
OKTA_API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
# set org name, obviously this is just orgName
OKTA_ORG="orgName"
# file name to output results to
output="userAppAssignments.txt"

# colour codes because pretty means professional
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
MAG='\033[0;35m'
RED='\033[0;31m'

# gets all applications, then passes to jq which filters the results and holds onto just the 'id' and 'label' fields
app_details=$(curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[] | "\(.id) \(.label)"')

echo "${CYAN}Gathering the facts...${NC}"
# loops through each app_id and fetches users, then appends to output file
while read -r app_info; do
    app_id=$(echo "$app_info" | awk '{print $1}')
    app_label=$(echo "$app_info" | awk '{$1=""; print $0}')
    echo "${GREEN}Gathering member list for $app_label.${NC}"
    echo "Application ID: $app_id - Label: $app_label" >> "$output"
    # takes the app_id, passes it back into the curl request, and adds /users to fetch the list of users for each app, then passes to jq to filter for 'cred.userName' to make reading easier
    curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps/$app_id/users" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq -r '.[].credentials.userName' >> "$output"
    echo "" >> "$output"

done <<< "$app_details"
echo "Finished. Check $output"