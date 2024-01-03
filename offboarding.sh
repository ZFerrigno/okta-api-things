#!/bin/bash

# Introduction
#   This script collects the user_id from the email addr, gets the assigned groups and apps, suspends the account, then sets the app assignments to individual to allow for removal.


# ----------------------------------------------------------------------------------

# Set API token and organization (assuming these are defined elsewhere)
API_TOKEN=$(security find-generic-password -a "name" -s "okta-api" -w)
ORG="orgName"

# colour codes because pretty means professional
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour
MAG='\033[0;35m'
RED='\033[0;31m'

# ----------------------------------------------------------------------------------


# give email address, format as user.name@orgName.com
read -p "Enter the user's email address: " USER_EMAIL

# the script only works for test users for now
#if [[ "$USER_EMAIL" != *"test"* ]]; then
#    echo "The script only works for test users. Exiting..."
#    exit 1
#fi

# get user id
user_id=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users?search=profile.login%20eq%20%22${USER_EMAIL}%22" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[0].id')
echo "User ID for ${CYAN}$USER_EMAIL${NC} is: ${GREEN}$user_id${NC}"


# get groups
groups=$(curl -s -X GET "https://${ORG}.okta.com/api/v1/users/${user_id}/groups?limit=200" -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].profile.name')
echo "\n${MAG}Groups${NC} for user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$groups${NC}"

                                                                                                                                
# get apps
apps=$(curl -s -X GET https://${ORG}.okta.com/api/v1/apps\?filter\=user.id+eq+%22${user_id}%22\&limit\=200 -H "Authorization: SSWS ${API_TOKEN}" | jq '.[] | "\(.label) \(.id)"')
echo "\n${MAG}Applications${NC} assigned to user ${CYAN}$USER_EMAIL${NC}:"
echo "${GREEN}$apps${NC}"


# get app IDs assigned to user
get_user_app_ids() {
    apps=$(curl -s -X GET https://${ORG}.okta.com/api/v1/apps\?filter\=user.id+eq+%22${user_id}%22\&limit\=200 -H "Authorization: SSWS ${API_TOKEN}" | jq -r '.[].id')
    echo "$apps"
}
# Get app IDs assigned to user
user_app_ids=$(get_user_app_ids)



# -------------------------------------------------------------------------------------------------------------



# suspend user account
curl -s -X POST https://${ORG}.okta.com/api/v1/users/${user_id}/lifecycle/suspend -H "Authorization: SSWS ${API_TOKEN}"
echo "${GREEN}$user_id $USER_EMAIL${NC} ${RED}suspended${NC}"

# set scope to USER for each app
echo "${CYAN}Setting app assignments to USER for $USER_EMAIL${NC}" 
set_scope_to_user() {
    user_app_ids=$1  # Passed as argument
    pid=$$ # Process ID of the current script
    for app_id in $user_app_ids; do
        # Set scope to USER for each app
        curl --silent -X POST "https://${ORG}.okta.com/api/v1/apps/$app_id/users/${user_id}" -H "Authorization: SSWS ${API_TOKEN}" -d '{"scope": "USER"}' -H 'accept: application/json, text/javascript' -H 'content-type: application/json' > /dev/null
        echo "Completed ${GREEN}$app_id${NC}"
    done
}
# Set scope to USER for each assigned app
set_scope_to_user "$user_app_ids"


# remove app assignments from user
echo "${CYAN}Removing app assignments from $USER_EMAIL${NC}"
remove_app_assignments() {
    local user_id=$1
    local org=$2
    local api_token=$3
    
    user_app_ids=$(get_user_app_ids)
    
    for app_id in $user_app_ids; do
        curl -X DELETE "https://${org}.okta.com/api/v1/apps/${app_id}/users/${user_id}" -H "Authorization: SSWS ${api_token}"
        echo "${MAG}Removed $USER_EMAIL from app:${NC} ${GREEN}$app_id${NC}"
    done
}
# remove app assignments from user
remove_app_assignments "$user_id" "$ORG" "$API_TOKEN"

# -------------------------------------------------------------------------------------

echo "${GREEN}$USER_EMAIL has been deprovisioned in Okta but there are still manual steps."
echo "${NC}${RED} CHECK 1PASSWORD${NC}"
echo "${NC}${RED} Check the deprovisioning tasks in Okta, Sanity check yourself with each application${NC}"
echo "${NC}${RED} Log changes on the offboarding ticket${NC}"