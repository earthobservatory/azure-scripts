#!/bin/bash

# Starts all instances through the Azure CLI
# This script should be run on any machine that has credentials for the Azure CLI

RESOURCE_GROUP="HySDS_Prod_Terra"

MOZART="MozartVMProdTerra"
METRICS="MetricsVMProdTerra"
GRQ="GRQVMProdTerra"
FACTOTUM="FactotumVMProdTerra"
CI="CIVMProdTerra"

az vm start -g "$RESOURCE_GROUP" -n "$MOZART" --no-wait
az vm start -g "$RESOURCE_GROUP" -n "$METRICS" --no-wait
az vm start -g "$RESOURCE_GROUP" -n "$GRQ" --no-wait
az vm start -g "$RESOURCE_GROUP" -n "$FACTOTUM" --no-wait
az vm start -g "$RESOURCE_GROUP" -n "$CI" --no-wait
