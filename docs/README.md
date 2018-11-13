# Helper scripts

## `1_scrape_scihub-1.sh` - Scrape SciHub for Data Manually

### Script Location

Mozart

### Purpose

A manual way to scrape acquisition metadata from ESA for Sentinel-1.

## `2_qquery-1.sh` - Submit job for `qquery` and slinging of SLCs

### Script Location

Mozart

### Purpose

A manual way to submit a job for `qquery` and if successful, spin up sling jobs

## `3_scrape_s1_orbit-1.sh` - Querying and ingest of Sentinel-1 orbit and calibration files

### Script Location

Mozart

### Purpose

A manual way to query and ingest Sentinel-1 orbit and calibration files.

## `chmod_scripts.sh` - Make Python scripts executable

### Script Location

Factotum

### Purpose

This script `chmod`s all Python scripts in `/home/ops/verdi/ops` to executable

## `fab_push_aria_pkgs-1.sh` - Push ARIA packages to Factotum and Verdi

### Script Location

Mozart

### Purpose

Pushes ARIA package and scripts to Factotum and Verdi. Refer to [this article](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation#push-out-aria-adaptation-configuration-and-repositories) for the origin of this command.
