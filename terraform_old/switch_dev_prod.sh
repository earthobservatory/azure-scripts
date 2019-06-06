#!/bin/bash

# This script switches the .tfstate files between development and production

rm *.tfstate.backup

# Check if .prod exists. If .prod exists, the system is currently in dev mode
# and shall be switched to production
if [ -f "terraform.tfstate.prod" ]; then
    # Switch system to production
    mv terraform.tfstate terraform.tfstate.dev

    mv terraform.tfstate.prod terraform.tfstate
    echo "System switched to production"
# If not, check if .dev exists. If .dev exists, the system is in prod mode and
# shall be switched to development
elif [ -f "terraform.tfstate.dev" ]; then
    # Switch system to development
    mv terraform.tfstate terraform.tfstate.prod
    mv terraform.tfstate.dev terraform.tfstate
    echo "System switched to development"
else
    # Else, ask the user what mode they want so that this script can rename
    # their current .tfstate file
    echo "It seems like you do not have another .tfstate file"
    read -e -p "Set the environment to (d)evelopment or (p)roduction: " MODE
    if [ "$MODE" = "d" ]; then
        mv terraform.tfstate terraform.tfstate.prod
    elif [ "$MODE" = "p" ]; then
        mv terraform.tfstate terraform.tfstate.dev
    fi
fi
