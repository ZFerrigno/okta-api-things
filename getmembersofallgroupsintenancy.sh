#!/bin/bash

# IMPORTANT, you need to add your Okta superadmin API token to the keychain using "security add-generic-password -a "accountname" -s "give-it-a-name" -w "API_TOKEN"
# Then reference it in the line below
API_TOKEN=$(security find-generic-password -a "zachferrigno" -s "okta-api" -w)

# Fetch group IDs and names
group_info=$(curl -s -X GET "https://apperio.okta.com/api/v1/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}")

# Loop through each group
echo "$group_info" | jq -r '.[] | "\(.id) \(.profile.name)"' | while read -r id name; do
    # Fetch users for the current group
    users=$(curl -s -X GET "https://apperio.okta.com/api/v1/groups/${id}/users" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.login')

    # Output the group ID, name, and associated users
    echo "Group ID: $id"
    echo "Group Name: $name"
    echo "Members: "
    echo "$users"
    echo "-----------------------------"
done
