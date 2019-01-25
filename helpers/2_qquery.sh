#!/bin/bash

# This script runs qquery on SciHub and sling of S1 SLCs
# The origins of the commands can be traced back to https://github.com/hysds/ariamh/wiki/ARIA-Adaptation
# NOTE: This script should only be run after defining one or more AOIs!
# WARNING: Large AOIs may take a LONG time to run!

export FACTOTUM_PVT_IP=$(grep ^FACTOTUM_PVT_IP ~/.sds/config | awk '{print $2}')
export KEY_FILENAME=$(grep ^KEY_FILENAME ~/.sds/config | awk '{print $2}')

export QQUERY_RELEASE_NUMBER=release-20180612 # This release number should be the same as the qquery SDS package
export SPYYYDERMAN_RELEASE_NUMBER=release-20180129 # This release number should be the same as the spyyyderman SDS package

ssh -i $KEY_FILENAME ops@${FACTOTUM_PVT_IP} "source ~/verdi/bin/activate; ~/verdi/ops/qquery/qquery/cron.py --tag=$QQUERY_RELEASE_NUMBER --sling_tag=$SPYYYDERMAN_RELEASE_NUMBER asf"
# Comment the line above and uncomment the line below to qquery from scihub (ESA's official source) instead of asf (Alaskan Satellite Facility mirror)
#ssh -i $KEY_FILENAME ops@${FACTOTUM_PVT_IP} "source ~/verdi/bin/activate; ~/verdi/ops/qquery/qquery/cron.py --tag=$QQUERY_RELEASE_NUMBER --sling_tag=$SPYYYDERMAN_RELEASE_NUMBER scihub"
