#!/bin/bash
# just gets a full json file of the config for all applications, useful but boring

# okta api token
OKTA_API_TOKEN=$(security find-generic-password -a "entryName" -s "okta-api" -w)
# org name
OKTA_ORG="orgName"
echo "Grabbing a full JSON out for all applications..."
curl -s -X GET "https://$OKTA_ORG.okta.com/api/v1/apps?limit=200" -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq > applications.json
echo "Finished. Check applications.json"