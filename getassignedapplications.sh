#!/bin/bash

# Set your Okta API token
OKTA_API_TOKEN=$(security find-generic-password -a "zachferrigno" -s "okta-api" -w)
OKTA_ORG="apperio"

# Fetch list of applications
function get_applications() {
  curl -s -X GET \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: SSWS $OKTA_API_TOKEN" \
    "https://$OKTA_ORG.okta.com/api/v1/apps"
}

# Fetch users assigned to a specific application
function get_users_for_app() {
  app_id="$1"
  curl -s -X GET \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: SSWS $OKTA_API_TOKEN" \
    "https://$OKTA_ORG.okta.com/api/v1/apps/$app_id/users"
}

# Get list of applications
applications=$(get_applications)

# Loop through each application and fetch users
for row in $(echo "${applications}" | jq -r '.[] | @base64'); do
  unset users
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  app_id=$(_jq '.id')
  app_name=$(_jq '.name')

  echo "Application: ${app_name}"

  # Get users for this application
  users=$(get_users_for_app $app_id)

  # Print users assigned to the application
  echo "Users:"
  echo "${users}" | jq -r '.[] | "\(.id) \(.credentials.userName)"'
  echo "-------------------"
done
