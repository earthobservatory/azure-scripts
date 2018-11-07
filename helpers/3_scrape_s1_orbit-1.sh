#!/bin/bash

# This script scrapes and ingests Sentinel-1 orbital and calibration data from ESA
# The origins of the commands can be traced back to https://github.com/hysds/ariamh/wiki/ARIA-Adaptation

export FACTOTUM_PVT_IP=$(grep ^FACTOTUM_PVT_IP /home/ops/.sds/config | awk '{print $2}')
export GRQ_PVT_IP=$(grep ^GRQ_PVT_IP /home/ops/.sds/config | awk '{print $2}')
export KEY_FILENAME=$(grep ^KEY_FILENAME /home/ops/.sds/config | awk '{print $2}')

# Note that the tag is the version of s1_qc_ingest's currently installed version, we are using a modified release-20180627 meant for Azure only
ssh -i $KEY_FILENAME ops@${FACTOTUM_PVT_IP} "source ~/verdi/bin/activate; ~/verdi/ops/s1_qc_ingest/cron_crawler.py --type orbit --dataset_version v1.1 --tag azure-dev http://${GRQ_PVT_IP}:9200"
