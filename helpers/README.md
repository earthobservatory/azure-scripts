# Helper scripts

## Legacy Pipeline Manual Operation

The scripts under the Legacy Pipeline folder are meant to be used with the
legacy pipeline, not the new standard pipeline. These scripts make it easy to run jobs that are otherwise started by cron.

### `1_scrape_scihub-1.sh` - Scrape SciHub for Data Manually

**Script Location**: Mozart

**Purpose**: A manual way to scrape acquisition metadata from ESA for Sentinel-1 without using cron.
This scraper only works with the older versions of [scihub\_acquisition\_scraper](https://github.com/hysds/scihub_acquisition_scraper) before 2019.

### `2_qquery-1.sh` - Submit job for `qquery` and slinging of SLCs

**Script Location**: Mozart

**Purpose**: A manual way to submit a job for `qquery` and if successful, spin up sling jobs (which downloads SLCs or radar images) without using cron.

### `3_scrape_s1_orbit-1.sh` - Querying and ingest of Sentinel-1 orbit and calibration files

**Script Location**: Mozart

**Purpose**: A manual way to query and ingest Sentinel-1 orbit and calibration files without using cron.

## Ops helper scripts

### `create_update_vmss.sh` - Create and update Virtual Machine Scale Sets

**Script location**: Mozart

**Purpose**: Creates or updates Virtual Machine Scale Sets (Azure equivalent of AWS Autoscaling Groups). Edit the script's parameters first before running it. This script is eventually meant to be merged into `sdscli`.

### `chmod_scripts.sh` - Make Python scripts executable

**Script Location**: Factotum

**Purpose**: This script `chmod`s all Python scripts in `/home/ops/verdi/ops` to executable.
This script should not be run on Mozart as it will affect Git repositories.

### `fab_push_aria_pkgs.sh` - Push ARIA packages to Factotum and Verdi

**Script Location**: Mozart

**Purpose**: Pushes ARIA package and scripts to Factotum and Verdi. Refer to
[this article](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation#push-out-aria-adaptation-configuration-and-repositories)
for the origin of this command.

### `start_all.sh` - Start all components in the cluster

**Script Location**: Any computer with valid credentials for Azure CLI

**Purpose**: Starts up all virtual machines for the HySDS cluster.

### `stop_dealloc_all.sh` - Stops all components in the cluster

**Script Location**: Any computer with valid credentials for Azure CLI

**Purpose**: Stops all virtual machines for the HySDS cluster and deallocates them (i.e. it will no longer incur costs).
