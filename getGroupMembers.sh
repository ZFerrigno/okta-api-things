#!/bin/bash

# collects membership for all groups in the organisation

API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
ORG="orgName"
output="groupMembers.txt"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
MAG='\033[0;35m'
RED='\033[0;31m'

# gets all groups
group_info=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}")

# takes above group info, passes through jq filtering for profile.name and id. id used for for the script, profile.name used for humans to read
echo "$group_info" | jq -r '.[] | "\(.id) \(.profile.name)"' | while read -r id name; do
    echo "${MAG}Group members captured for $name${NC}"

    # append group details to the file
    {
        echo "${GREEN}Group ID: $id${NC}"
        echo "${GREEN}Group Name: $name{$NC}"

        # fetch users for the current group
        users=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups/${id}/users" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.login')

        # output the associated users
        echo "${GREEN}Members:${NC} "
        echo "${CYAN}$users${NC}"
        echo "-----------------------------"
    } >> "$output" # append output to file
done
echo "${GREEN}Finished. Check $output"
