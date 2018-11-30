# Shell based Deployment Scripts

## Files

| Filename | Description |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `envvars.sh` | Shell script that defines constants for your resources. |
| `install_phase1.sh` | Terraform file describing the base image VM |
| `install_phase2.sh` | Terraform file describing the base image VM |
| `install_phase3.sh` | Terraform file describing the major static components of HySDS, namely the Mozart, Metrics, GRQ, Factotum, and CI virtual machines |
| `install_phase4.sh` | Terraform file describing the Verdi base image creator VM |
| `https_autoconfig.sh` | Automagical configuration of a proper HTTPS certificate for a HySDS instance that has a web interface |
| `dump_parameters.sh` | A script that dumps parameters necessary for HySDS configuration such as IP addresses and keys to the terminal |

## Phase 0 - Configure `envvars.sh`

`envvars.sh` contains the desired names for your resources. Please edit the values in the script before attempting to run any of the other scripts. `envvars.sh` is not meant to be run on its own.

This set of scripts make a few assumptions:

- ...that you have already configured a resource group. You have to edit the `AZ_RESOURCE_GROUP` variable in `envvars.sh` to match that of your actual resource group's name
- ...that you already have the Azure CLI tool installed
- ...that you have sufficient permissions to deploy assets like networking and virtual machines. It is highly recommended to have Owner permissions

## Phase 1 - Network assets provisioning

Phase 1 provisions networking assets, such as a virtual network, network security groups, IP addresses, network interface cards, and storage containers.

Run `$ sh install_phase1.sh`

## Phase 2 - Base image creation

Phase 2 creates a base image that the actual VMs are going to be based on. You will need to generate an SSH keypair beforehand so that the tool can authenticate to the base VM in order to configure it.

Run `$ sh install_phase2.sh`

## Phase 3 - HySDS VMs deployment

Phase 3 spins up actual VMs used by the HySDS framework, namely, Mozart, Metrics, GRQ, Factotum, and CI. The tool will print the IP addresses of the VMs upon successful deployment.

Run `$ sh install_phase3.sh`

## Phase 4 - HySDS cluster configuration

Phase 4 aims to automatically configure the VMs. The configuration encompasses 3 aspects: expansion of filesystem, installation of Puppet modules and for Mozart specifically, the installation of the HySDS framework. You will still have to manually configure HySDS by the end of this script.

Keep in mind that Mozart is configured last due to its relative complexity. The other nodes are configured asynchronously to save time and prevent network dropouts, by using the `screen` command to spawn a virtual terminal and performing the installation/configuration in there, and then immediately exiting the SSH session and moving on to the next machine. If you need to access that virtual terminal for debugging reasons, you can SSH into that specific machine, log in as root with `sudo su -` and simply key in `screen -x` to attach to that terminal.

In addition to spawning a virtual terminal, all `stdout` output is also logged to a `.log` file for debugging purposes.

Run `$ sh install_phase4.sh`

## Dump Parameters - Automatic configuration dumping tool

The `dump_parameters.sh` script automatically dumps configuration parameters for the user to view, which also makes the subsequent `sds configure` part easier. Typical parameters dumped are:

- VM IP Addresses
- Storage account name
- Keys for accessing Instrumentation and Storage
- Endpoints

Some of the parameters emitted are based on the parameters set by `envvars.sh`, and may not be correct if `envvars.sh` is incorrect.

Run `$ sh dump_parameters.sh`