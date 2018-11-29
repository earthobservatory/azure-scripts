# HySDS/Azure scripts

This repository contains scripts meant to automate and ease the deployment and operation of a HySDS cluster with ARIA, with a focus on deployment in the Microsoft Azure cloud IaaS.

The deployment scripts are written in Terraform's HCL and standard `sh` shell script respectively in `terraform/` and `shell/`, and are meant to be run on the client side. However, these deployment scripts are not perfect and there may be issues encountered during deployment due to issues like bad connectivity and so on. These scripts do not perform any input sanitisation either, so care must be taken during data entry.

## Directories

### `terraform/` - Terraform version of the deployment scripts

The Terraform version provides a "versionable" way to write Infrastructure as Code (IAC), and provides a quick way to deploy, and to alter the architecture without having to delete the entire resource group (only applies under certain scenarios). The Terraform version is written in a hybrid manner: while most of the infrastructure is described using Terraform's `.tf` files, there are a few scripts that are run by Terraform using [null resources](https://www.terraform.io/docs/provisioners/null_resource.html) that makes Terraform more flexible.

### `shell/` - Standard UNIX shell version of the deployment scripts

The shell script version are written in standard `sh` shell and provides a semi-automated way of deploying a HySDS cluster. The rationale for making shell scripts instead of a more powerful tool in an interpreted language like Python is twofold: to reduce code needed and to improve cross-platform compatibility. Occasionally however, Python helpers are written for more advanced functionality such as JSON parsing.

### `helpers/` - Helper scripts for the ARIA adaptation

Shell scripts meant to make life easier for the user. Further documentation is provided in another README.md file in this directory.

### `docs/` - Documentation

Miscellaneous documentation written in Markdown for resolving common problems you may encounter with the system, as well as operational guides.

## Terraform Version Usage

1. Download and install Terraform on your machine (preferably a UNIX-like system such as a Mac or a Linux machine) with [this link](https://www.terraform.io/downloads.html).

2. Edit the `var_values.tfvars` file to suit your configuration.

3. Run `terraform init` in order for Terraform to download the appropriate tools for working with Azure.

4. Run `terraform apply -var-file=var_values.tfvars`, verify that the parameters are correct and type `yes` to apply the changes.

5. Once everything is done, run `az ad sp create-for-rbac --sdk-auth` in your command line to create an application and retrieve the parameters necessary for `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET_KEY`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID` when you're configuring the HySDS cluster through `sds configure`.

### Redeploying a failed asset

If at any point, the deployment of an asset is interrupted by, say, connection issues, you can redeploy the failed asset by "tainting" the asset and allowing Terraform to recreate it. For example, if you want to redeploy the Mozart instance, simply issue the command `terraform taint azurerm_virtual_machine.mozart` and Terraform will destroy and recreate the instance for you. Keep in mind that you will have to set up that instance manually afterwards.

### Deficiencies of Terraform

Terraform in essence is a cloud architecture orchestration tool; a declarative language, rather than procedural (contrasting with the shell version). This means that it only concerns itself with assets and dependencies, not the state of the asset themselves. Terraform can only spin up VMs, and cannot alter their power states and so on. In the `.tf` files, you may notice `null_resource`s being created. Null resources are resources not tied to an actual cloud resource, but rather to add a bit of procedural logic in an otherwise declarative environment. For example, the deallocation and generalization of the Base VM is done through an external shell script, through a `null_resource`, not through Terraform's own system because Terraform does not handle these tasks.

These null resources are not automatically destroyed, and must be destroyed with the rest of the system when running `terraform destroy -var-file=var_values.tfvars`

## Shell Version Usage

### Phase 0 - Configure `envvars.sh`

`envvars.sh` contains the desired names for your resources. Please edit the values in the script before attempting to run any of the other scripts. `envvars.sh` is not meant to be run on its own.

This set of scripts make a few assumptions:

- ...that you have already configured a resource group. You have to edit the `AZ_RESOURCE_GROUP` variable in `envvars.sh` to match that of your actual resource group's name
- ...that you already have the Azure CLI tool installed
- ...that you have sufficient permissions to deploy assets like networking and virtual machines. It is highly recommended to have Owner permissions

### Phase 1 - Network assets provisioning

Phase 1 provisions networking assets, such as a virtual network, network security groups, IP addresses, network interface cards, and storage containers.

Run `$ sh install_phase1.sh`

### Phase 2 - Base image creation

Phase 2 creates a base image that the actual VMs are going to be based on. You will need to generate an SSH keypair beforehand so that the tool can authenticate to the base VM in order to configure it.

Run `$ sh install_phase2.sh`

### Phase 3 - HySDS VMs deployment

Phase 3 spins up actual VMs used by the HySDS framework, namely, Mozart, Metrics, GRQ, Factotum, and CI. The tool will print the IP addresses of the VMs upon successful deployment.

Run `$ sh install_phase3.sh`

### Phase 4 - HySDS cluster configuration

Phase 4 aims to automatically configure the VMs. The configuration encompasses 3 aspects: expansion of filesystem, installation of Puppet modules and for Mozart specifically, the installation of the HySDS framework. You will still have to manually configure HySDS by the end of this script.

Keep in mind that Mozart is configured last due to its relative complexity. The other nodes are configured asynchronously to save time and prevent network dropouts, by using the `screen` command to spawn a virtual terminal and performing the installation/configuration in there, and then immediately exiting the SSH session and moving on to the next machine. If you need to access that virtual terminal for debugging reasons, you can SSH into that specific machine, log in as root with `sudo su -` and simply key in `screen -x` to attach to that terminal.

In addition to spawning a virtual terminal, all `stdout` output is also logged to a `.log` file for debugging purposes.

Run `$ sh install_phase4.sh`

### Dump Parameters - Automatic configuration dumping tool

The `dump_parameters.sh` script automatically dumps configuration parameters for the user to view, which also makes the subsequent `sds configure` part easier. Typical parameters dumped are:

- VM IP Addresses
- Storage account name
- Keys for accessing Instrumentation and Storage
- Endpoints

Some of the parameters emitted are based on the parameters set by `envvars.sh`, and may not be correct if `envvars.sh` is incorrect.

Run `$ sh dump_parameters.sh`

## Post deployment

Further configuration is still required after you run either the Terraform or the shell versions of the deployment scripts. Some of the tasks that you need to do includes:

1. Set up CI by navigating to `http://[CI_FQDN]:8080` and proceed as admin, and retrieve Jenkin's API key and the current administrative user's username. Optionally, you might want to update Jenkins before setting it up by downloading the [latest Jenkins `.war` file](http://mirrors.jenkins.io/war-stable/latest/jenkins.war) and replacing the old version in `/usr/local/bin/jenkins.war`.
2. `sds configure` to set up the environment constants used by HySDS on Mozart, one of which is to add `JENKINS_API_KEY` as retrieved previously.
3. Verify that ElasticSearch is running on Mozart, Metrics and GRQ instances by running `$ systemctl status elasticsearch` on those instances. If it's not up, run `# systemctl start elasticsearch`.
4. `sds update all -f` to update all components of HySDS.
5. `sds start all -f` to start all components of HySDS, and use `sds status all` to verify that all components are up and running.
6. (Highly recommended) Improve Docker performance on Factotum by using [this guide](docs/fix_slow_docker.md).
7. (Optional) Set up real HTTPS certificates instead of using self-signed ones by running `sh /home/ops/https_autoconfig.sh` on the servers that need it (mainly Mozart, GRQ and Metrics). The current script only supports DNS verification through CloudFlare.
8. (Optional) Set up the ARIA adaptation using instructions from [here](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation).

## Good to knows/Caveats

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

`$ brew unlink azure-cli`

`$ brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/3894a0d2095f48136ce1af5ebd5ba42dd38f1dac/Formula/azure-cli.rb`

## Other known issues

### `yum -y update` hangs during Phase 2

Symptoms: During the provisioning of the base VM in phase 2, a `yum -y update` command causes the base VM to be unresponsive. There may also be a `ssh_exchange_identification: read: Connection reset by peer` message returned if one attempts to SSH into the VM.

Reason: The `yum -y update` command is CPU intensive, and for some reason, the deprovisioning commands is run in parallel with the package updater, causing the user to be unable to SSH back into the machine.

Solution: The `yum -y update` command has been moved from phase 2 to phase 4. The deprovisioning commands is explicitly run on another SSH session right after the installation of necessary yum packages.

## Feedback

If you encounter any issues with the script, please do not hesitate to open an issue on this repo.
