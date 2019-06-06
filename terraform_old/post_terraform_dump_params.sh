#!/bin/bash

# This script dumps parameters necessary for HySDS configuration, but is also useful in debugging
# This is AZURE SPECIFIC!

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

source envvars.sh

echo "⚙️ Server parameter dumping tool⚙️"
echo "This tool dumps parameters necessary for server configuration, such as for HySDS"
echo "This tool is AZURE SPECIFIC!"
echo

echo "✏️  Tenant ID/AZURE_TENANT_ID: "
if [ $PYTHON_VERSION = "3" ]; then
  az account show | python -c "import sys, json; print(json.load(sys.stdin)['tenantId'])"
else
  az account show | python -c "import sys, json; print json.load(sys.stdin)['tenantId']"
fi
echo

echo "✏️  Subscription ID/AZURE_SUBSCRIPTION_ID: "
if [ $PYTHON_VERSION = "3" ]; then
  az account show | python -c "import sys, json; print(json.load(sys.stdin)['id'])"
else
  az account show | python -c "import sys, json; print json.load(sys.stdin)['id']"
fi
echo

echo "✏️  As for the following parameters, please run the command below ONLY ONCE:"
echo "AZURE_CLIENT_ID, AZURE_CLIENT_SECRET_KEY"
echo "$ az ad sp create-for-rbac --sdk-auth"
echo