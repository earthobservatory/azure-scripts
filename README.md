# HySDS/Azure automatic deployment scripts

This repository contains a set of scripts meant to automatically deploy a HySDS cluster to Microsoft Azure.

These automated deploy scripts are written in standard `sh` shell and provides a semi-automated way of deploying a HySDS cluster. The rationale for making shell scripts instead of a more powerful tool in an interpreted language like Python is twofold: to reduce code needed and to improve cross-platform compatibility. Occasionally however, Python helpers are written for more advanced functionality such as JSON parsing.

However, these scripts are not perfect and there may be issues encountered during deployment due to issues like bad connectivity and so on. These scripts do not perform any input sanitisation, so care must be taken during data entry.

## Usage

### Configure `envvars.sh`

`envvars.sh` contains the desired names for your resources. Please edit the values in the script before attempting to run any of the other scripts. `envvars.sh` is not meant to be run on its own.

This set of scripts make a few assumptions:

- ...that you have already configured a resource group. You have to edit the `AZ_RESOURCE_GROUP` variable in `envvars.sh` to match that of your actual resource group's name
- ...that you already have the Azure CLI tool installed
- ...that you have sufficient permissions to deploy assets like networking and virtual machines

### Phase 1 - Network assets provisioning

Phase 1 provisions networking assets, such as a virtual network, network security groups, IP addresses, network interface cards, and storage containers.

`sh install_phase1.sh`

### Phase 2 - Base image creation

Phase 2 creates a base image that the actual VMs are going to be based on. You will need to generate an SSH keypair beforehand so that you can authenticate to the base VM in order to configure it.

`sh install_phase2.sh`

### Phase 3 - HySDS VMs deployment

Phase 3 deploys actual VMs used by the HySDS framework, namely, Mozart, Metrics, GRQ, Factotum, and CI. The tool will print the IP addresses of the VMs upon successful deployment.

`sh install_phase3.sh`

### Phase 4 - HySDS cluster configuration

Phase 4 aims to automatically configure the VMs. The configuration encompasses 3 aspects: expansion of filesystem, installation of Puppet modules and for Mozart specifically, the installation of the HySDS framework. You will still have to manually configure HySDS by the end of this script.

Keep in mind that Mozart is configured last due to its relative complexity. The other nodes are configured asynchronously to save time and prevent network dropouts, by using the `screen` command to spawn a virtual terminal and performing the installation/configuration in there, and then immediately exiting the SSH session and moving on to the next machine. If you need to access that virtual terminal for debugging reasons, you can SSH into that specific machine, log in as root with `sudo su -` and simply key in `screen -x` to attach to that terminal.

In addition to spawning a virtual terminal, all `stdout` output is also logged to a `.log` file for debugging purposes.

`sh install_phase4.sh`

### Dump Parameters - Automatic configuration dumping tool

The `dump_parameters.sh` script automatically dumps configuration parameters for the user to view. Typical parameters dumped are:

- VM IP Addresses
- Storage account name
- Keys for accessing Instrumentation and Storage
- Endpoints

Some of the parameters emitted are based on the parameters set by `envvars.sh`, and may not be correct if `envvars.sh` is incorrect.

## Good to knows

- Make sure that Azure is properly configured with `Microsoft.Network`, `Microsoft.Compute` and `Microsoft.Storage` resource providers all enabled
- Triple check the environment variables defined in the `envvars.sh` file before deploying, such as the name of the resource group, the names of the resources to be created etc.
- The scripts are not meant to be run multiple times. It is best to run them only once
- Always perform all tasks on a strong and reliable connection to avoid any potential failures requiring the scripts to be restarted
- The user is required to manually copy and paste certain values from their system or display into the script when necessary. This is to reduce the complexity of the script. Certain more advanced features like JSON parsing is done via piping data into Python
- You may need to switch account subscriptions within your Azure CLI tool using the command `azure account set -s [subscription ID]`
- These scripts use Python's built-in `json` library to process JSON emitted by the `az` tool. The script automatically detects the Python version present on the system
- All SSH/SCP commands are run with `-o StrictHostKeyChecking=no` to skip having to answer `yes` when connecting to the VMs for the first time

## macOS specific issues

### Phase 2 fails with `No module named 'azure.mgmt.compute'` during creation of VM

This is caused by a faulty version of the `az` tool (namely 2.0.47) installed by Homebrew (if you used Homebrew to install the package). You have to downgrade the tool to 2.0.46 manually with the following commands. This assumes you already have the `az` tool installed.

`brew unlink azure-cli`

`brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/3894a0d2095f48136ce1af5ebd5ba42dd38f1dac/Formula/azure-cli.rb`

## Feedback

If you encounter any issues with the script, please do not hesitate to open an issue on this repo.
