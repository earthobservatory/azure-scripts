#!/bin/bash

# This script automatically pushes ARIA packages onto Factotum and Verdi

fab -f ~/.sds/cluster.py -R factotum,verdi update_aria_packages
