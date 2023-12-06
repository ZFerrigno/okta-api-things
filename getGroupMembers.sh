#!/bin/bash

API_TOKEN=$(security find-generic-password -a "" -s "okta-api" -w)
ORG=""
output="groupMembers.txt"

group_info=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}")

echo "$group_info" | jq -r '.[] | "\(.id) \(.profile.name)"' | while read -r id name; do
    echo "Group members captured for $name" # Print group name to console

    # Append group details to the file
    {
        echo "Group ID: $id"
        echo "Group Name: $name"

        # Fetch users for the current group
        users=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups/${id}/users" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.login')

        # Output the associated users
        echo "Members: "
        echo "$users"
        echo "-----------------------------"
    } >> "$output" # Append output to file
done
