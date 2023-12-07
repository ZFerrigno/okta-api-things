#!/bin/bash

# Retrieving API token from macOS keychain
API_TOKEN=$(security find-generic-password -a "zachferrigno" -s "okta-api" -w)
ORG="apperio"

# Color codes for formatting output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
MAG='\033[0;35m'
RED='\033[0;31m'


# Prompt the administrator to enter the user's email address
read -p "Enter the user's email address: " USER_EMAIL

# Fetching user ID using Okta's API
user_id=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users?search=profile.login%20eq%20%22${USER_EMAIL}%22" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[0].id')

if [ -z "$user_id" ]; then
  echo "User not found."
  exit 1
fi

echo "User ID for ${CYAN}$USER_EMAIL${NC} is: ${GREEN}$user_id${NC}"

# Fetching groups the user is a member of
groups=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users/${user_id}/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.name')

echo "\n${MAG}Groups${NC} for user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$groups${NC}"

# Fetching applications assigned to the user
apps=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users/${user_id}/appLinks" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].label')
apps_more=$(curl -s -X GET "https://$ORG.okta.com/api/v1/apps?search=user.id%20eq%20%22${user_id}%26expand=user/${user_id}?limit=200%22" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].label')

echo "\n${MAG}Applications${NC} assigned to user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$apps${NC}"

echo "\n${MAG}Continued Applications${NC} assigned to user ${CYAN}$USER_EMAIL{$NC} - ${RED}IMPORTANT NOTE:${NC} I don't yet know why some apps listed here don't show in the above list, it's confusing and weird but this workaround at least grabs everything for now "
echo "${GREEN}$apps_more${NC}"


