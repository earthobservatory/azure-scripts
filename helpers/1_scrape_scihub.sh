#!/bin/bash

# This script is an acquisition scraper for Sentinel-1 data and generates acquisition-S1-IW_SLC datasets
# The origins of the commands can be traced back to https://github.com/hysds/ariamh/wiki/ARIA-Adaptation

export FACTOTUM_PVT_IP=$(grep ^FACTOTUM_PVT_IP ~/.sds/config | awk '{print $2}')
export GRQ_PVT_IP=$(grep ^GRQ_PVT_IP ~/.sds/config | awk '{print $2}')
export KEY_FILENAME=$(grep ^KEY_FILENAME ~/.sds/config | awk '{print $2}')

export SCRAPER_RELEASE_NUMBER=release-20180604 # This release number should be the same as the scihub_acquisition_scraper SDS package

ssh -i $KEY_FILENAME ops@${FACTOTUM_PVT_IP} "source ~/verdi/bin/activate; ~/verdi/ops/scihub_acquisition_scraper/cron.py --tag=$SCRAPER_RELEASE_NUMBER opensearch http://${GRQ_PVT_IP}:9200/grq_v1.1_acquisition-s1-iw_slc/acquisition-S1-IW_SLC"
