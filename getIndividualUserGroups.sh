#!/bin/bash

# THIS SCRIPT SUCKS I'M NOT QUITE SURE HOW IT ENDED UP IN THIS ODD STATE, IT WORKS BUT IT DON'T WORK GOOD

API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
ORG="orgName"
output="groupMembers.txt"

read -p "Enter the user's name or ID: " user_input

group_info=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups?limit=200" -H "Authorization: SSWS $API_TOKEN")

echo "$group_info" | jq -r '.[] | "\(.id) \(.profile.name)"' | while read -r id name; do
    echo "Group members captured for $name"


    {
        echo "Group ID: $id"
        echo "Group Name: $name"

        # get users for group
        users=$(curl -s -X GET "https://$ORG.okta.com/api/v1/groups/${id}/users" -H "Authorization: SSWS $API_TOKEN")

        # check if user exists
        user_exists=$(echo "$users" | jq --arg user_input "$user_input" '.[] | select(.id==$user_input or .profile.name==$user_input)')

        if [ -n "$user_exists" ]; then
            echo "Members: "
            echo "$user_exists"
        else
            echo "User '$user_input' not found in this group."
        fi

        echo "-----------------------------"
    } >> "$output" # put in out file
done
echo "Finished. Check $output"
