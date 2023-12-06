#!/bin/bash

# Set your Okta API token
OKTA_API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
OKTA_ORG="apperio"

curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq > ../results/applicationsconfigurationconfig.json
