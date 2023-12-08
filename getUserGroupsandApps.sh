#!/bin/bash

# This takes a provided email address, and spits out all groups the user is a member of and all apps assigned to the member


# get api token
API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
ORG="orgName"

# colour codes because pretty means professional
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
MAG='\033[0;35m'
RED='\033[0;31m'


# give email address, format as user.name@orgName.com
read -p "Enter the user's email address: " USER_EMAIL

# get user id
user_id=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users?search=profile.login%20eq%20%22${USER_EMAIL}%22" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[0].id')

if [ -z "$user_id" ]; then
  echo "User not found."
  exit 1
fi

echo "User ID for ${CYAN}$USER_EMAIL${NC} is: ${GREEN}$user_id${NC}"

# get groups
groups=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users/${user_id}/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.name')

echo "\n${MAG}Groups${NC} for user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$groups${NC}"

# get apps
apps=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users/${user_id}/appLinks" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].label')
apps_more=$(curl -s -X GET "https://$ORG.okta.com/api/v1/apps?search=user.id%20eq%20%22${user_id}%26expand=user/${user_id}?limit=200%22" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].label')

echo "\n${MAG}Applications${NC} assigned to user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$apps${NC}"

echo "\n${MAG}Continued Applications${NC} assigned to user ${CYAN}$USER_EMAIL{$NC} - ${RED}IMPORTANT NOTE:${NC} I don't yet know why some apps listed here don't show in the above list, it's confusing and weird but this workaround at least grabs everything for now "
echo "${GREEN}$apps_more${NC}"


