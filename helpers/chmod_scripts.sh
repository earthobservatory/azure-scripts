#!/bin/bash
# This script automatically makes all python scripts executable for the verdi or factotum VMs
# This script is meant to be run on the VMs

# Do note that this script may impact folders with Git repos as it changes permissions
# Advise to run this script on machines other than Mozart

find /home/ops/verdi/ops -name "*.py" -exec chmod +x {} \;
