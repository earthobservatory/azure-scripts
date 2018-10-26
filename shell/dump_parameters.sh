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

echo "✏️  Resource Group:"
echo $AZ_RESOURCE_GROUP
echo

echo "✏️  VM IP addresses:"
if [ $PYTHON_VERSION = "3" ]; then
  az vm list-ip-addresses -g $AZ_RESOURCE_GROUP | python3 python_helpers/IP_Parser_Py3.py
else
  az vm list-ip-addresses -g $AZ_RESOURCE_GROUP | python python_helpers/IP_Parser_Py2.py
fi
echo "Useful for configuring HySDS: VM’s PUB_IP, PVT_IP and FQDN"
echo

echo "✏️  Storage account name/ID: "
if [ $PYTHON_VERSION = "3" ]; then
  export AZ_STORAGE_ACCOUNT_ID=`az storage account list -g $AZ_RESOURCE_GROUP | python -c "import sys, json; print(json.load(sys.stdin)[0]['id'])"`
else
  export AZ_STORAGE_ACCOUNT_ID=`az storage account list -g $AZ_RESOURCE_GROUP | python -c "import sys, json; print json.load(sys.stdin)[0]['id']"`
fi
echo $AZ_STORAGE_ACCOUNT_ID
echo "Useful for configuring HySDS: AZURE_STORAGE_ACCOUNT_NAME"
echo

echo "🔑  Instrumentation Key:"
az resource show -g $AZ_RESOURCE_GROUP -n $AZ_INSIGHTS_NAME --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey
echo "Useful for configuring HySDS: AZURE_TELEMETRY_KEY"
echo

echo "🔑  Storage Account Key:"
if [ $PYTHON_VERSION = "3" ]; then
  az storage account keys list -g $AZ_RESOURCE_GROUP -n $AZ_STORAGE_NAME | python -c "import sys, json; print(json.load(sys.stdin)[0]['value'])"
else
  az storage account keys list -g $AZ_RESOURCE_GROUP -n $AZ_STORAGE_NAME | python -c "import sys, json; print json.load(sys.stdin)[0]['value']"
fi
echo "Useful for configuring HySDS: AZURE_STORAGE_ACCOUNT_KEY"
echo

echo "✏️  Website endpoint"
echo "$AZ_STORAGE_NAME.blob.core.windows.net"
echo "Useful for configuring HySDS: AZURE_WEBSITE_ENDPOINT and AZURE_ENDPOINT"
echo

echo "✏️  Container names:"
echo "AZURE_CODE_CONTAINER: code"
echo "AZURE_DATASET_CONTAINER: dataset"
echo

echo "✏️  Verdi image location:"
echo "VERDI_PRIMER_IMAGE: "
echo "azure://$AZ_STORAGE_NAME.blob.core.windows.net/hysds-verdi-latest.tar.gz"
echo

echo "✏️  Storage protocol:"
echo "STORAGE_PROTOCOL: azure"
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

echo "✅  Tool Completed. Exiting..."
