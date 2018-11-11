#!/bin/bash
# This script automatically makes all python scripts executable for the verdi or factotum VMs
# This script is meant to be run on the VMs

find /home/ops/verdi/ops -name "*.py" -exec chmod +x {} \;
