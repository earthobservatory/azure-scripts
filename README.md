# HySDS - ARIA - Azure scripts

> Scripts to make your life easier when deploying HySDS and ARIA on Microsoft Azure cloud

<p align="center">
<img src="https://user-images.githubusercontent.com/1763181/52530077-0367d400-2d3a-11e9-984e-e936b137279d.png" width="33%" \>
</p>

- [ ] ⭕️ HySDS Core
- [ ] 📥 Installers (e.g. Puppet, Terraform)
- [ ] 🧩 Cluster Node-specific Packages (e.g. `mozart`, `figaro`)
- [ ] 🧰 Operational packages (e.g. `hysds-dockerfiles`)
- [ ] 🛰 PGE
- [x] 🛠 Helper Scripts
- [x] 📖 Documentation
- [ ] ❓ Miscellaneous / Uncategorized

This repository complements the official [HySDS](https://github.com/hysds) repos developed by JPL.

## Directories

### `terraform/` - Terraform version of the deployment scripts

This directory contains `.tf` files written in the HashiCorp configuration language (HCL) that describes a HySDS cluster. For more information on how to use it, refer to [the README file in the directory](terraform/README.md)

### `shell/` - Standard UNIX shell version of the deployment scripts

**NOTE: the shell version is currently deprecated!**

The shell script version is written in standard `sh` shell and provides a semi-automated way of deploying a HySDS cluster. The rationale for making shell scripts instead of a more powerful tool in an interpreted language like Python is twofold: to reduce code needed and to improve cross-platform compatibility. Occasionally, however, Python helpers are written for more advanced functionality such as JSON parsing.

### `helpers/` - Helper scripts for the ARIA adaptation

Shell scripts meant to make life easier for the user. Further documentation is provided in another README.md file in that directory.

### `docs/` - Documentation

Miscellaneous documentation written in Markdown for resolving common problems you may encounter with the system, as well as operational guides.

Currenty available documentation:

- [Fix slow Docker images on Factotum](docs/fix_slow_docker.md)

## Usage

Please refer to the README files inside the directories for detailed usage during the installation

### Post deployment - HySDS provisioning

Further configuration is still required after you run either the Terraform or the shell versions of the deployment scripts. Some of the tasks that you need to do includes:

1. Set up CI by navigating to `http://[CI_FQDN]:8080` and proceed as admin, and retrieve Jenkin's API key and the current administrative user's username. Optionally, you might want to update Jenkins before setting it up by downloading the [latest Jenkins `.war` file](http://mirrors.jenkins.io/war-stable/latest/jenkins.war) and replacing the old version in `/usr/local/bin/jenkins.war`.
2. `sds configure` to set up the environment constants used by HySDS on Mozart, one of which is to add `JENKINS_API_KEY` as retrieved previously.
3. Verify that ElasticSearch is running on Mozart, Metrics and GRQ instances by running `$ systemctl status elasticsearch` on those instances. If it's not up, run `# systemctl start elasticsearch`. Optionally, you might want to enable ElasticSearch on startup and run `# systemctl enable elasticsearch`.
4. `sds update all -f` to update all components of HySDS.
5. `sds start all -f` to start all components of HySDS, and use `sds status all` to verify that all components are up and running.
6. (Highly recommended) Improve Docker performance on Factotum by using [this guide](docs/fix_slow_docker.md).
7. (Optional) Set up real HTTPS certificates instead of using self-signed ones by running `sh /home/ops/https_autoconfig.sh` on the servers that need it (mainly Mozart, GRQ and Metrics). The current script only supports DNS verification through CloudFlare.
8. (Optional) Set up the ARIA adaptation using instructions from [here](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation).

### Post deployment - ARIA adaptation

This section is adapted from [hysds/ariamh](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation).

1. Stop the cluster with `$ sds stop all -f`
2. Backup your SDS configuration directory `~/.sds` with `$ mv ~/.sds ~/.sds.bak`
3. Download the custom SDS configuration on Mozart by running `$ cd ~; wget https://bitbucket.org/nvgdevteam/sds-config-aria/downloads/sds-config-aria-azure.tbz2`
4. Unpack the new template for the ARIA adaptation with `$ tar xvf sds-config-aria-azure.tbz2; mv sds-config-aria ~/.sds`
5. Restore your original configuration file `$ cp ~/.sds.bak/config ~/.sds/`
6. Copy the ARIA adaptation repositories to `~/mozart/ops` by running `$ cp -rf ~/.sds/repos/* ~/mozart/ops/`
7. Update the cluster with `$ sds update all -f`
8. (Optional) Increase the number of workers on Factotum for faster concurrent downloads by modifying `~/.sds/files/supervisord.conf.factotum`
9. Push the ARIA adaptation configuration files with `$ fab -f ~/.sds/cluster.py -R factotum,verdi update_aria_packages`, or alternatively run the `helpers/fab_push_aria_pkgs.sh` script
10. Ship the latest code configuration bundle for autoscaling workers with `$ sds ship`
11. Either reset or start the cluster with `$ sds reset all -f` or `$ sds start all -f`

### Post deployment - Autoscaling workers

#### Part 1

Part one configures the Verdi image creator VM to be ready for imaging

1. A Verdi image creator VM has already been set up for you through Terraform with its Puppet module installed. However, that image still requires additional configuration to be turned into an image
2. Push Azure configuration files from Mozart to Verdi with the following script, replacing `[SSH_KEY_NAME]` and `[VERDI_IP]` with the correct strings

    ```bash
    #!/bin/bash

    export PRIVATE_KEY_NAME=[SSH_KEY_NAME]
    export VERDI_IP=[VERDI_IP]

    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/azure_credentials.json ops@$VERDI_IP:~/.azure
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/config ops@$VERDI_IP:~/.azure
    ```

3. Change `VERDI_PVT_IP` in Mozart's `~/.sds/config` with the correct private IP for the Verdi image creator VM.
4. Update Verdi by running `sds update verdi -f` on Mozart
5. Push ARIA packages to Verdi by running `fab -f ~/.sds/cluster.py -R verdi update_aria_packages` on Mozart
6. Install Python packages on Verdi by running `source /home/ops/verdi/bin/activate; pip install azure msrest msrestazure ConfigParser` on Verdi
7. Ship the Verdi configuration with `sds ship` on Mozart
8. Deprovision the Verdi instance with `sudo waagent -deprovision -force`. This command can only be run ONCE and there is no going back!

#### Part 2

Part 2 creates the image and the scale set. Run these commands on a machine with Azure CLI with an account

1. Deallocate the VM  with `az vm deallocate --resource-group [AZURE_RESOURCE_GROUP] --name [VERDI_VM_NAME]`
2. Generalize the VM with `az vm generalize --resource-group [AZURE_RESOURCE_GROUP] --name [VERDI_VM_NAME]`
3. Create the VM image with `az image create --resource-group [AZURE_RESOURCE_GROUP] --name "HySDS_Verdi_YYYY-MM-DD-rcX" --source [VERDI_VM_NAME]`, with the format of the image name being in year, month, day and release candidate number
4. Create a file called `bundleurl.txt` by performing `echo BUNDLE_URL=azure://[AZURE_STORAGE_ACCOUNT_NAME].blob.core.windows.net/code/aria-ops.tbz2 > bundleurl.txt`, replacing \[AZURE_STORAGE_ACCOUNT_NAME\] with the name of your storage account
5. Create the scale set with

    ```bash
    az vmss create --custom-data bundleurl.txt --location southeastasia --name [VMSS_NAME] --vm-sku Standard_F32s_v2 --admin-username ops --instance-count 0 --single-placement-group true --lb-sku standard --priority low --authentication-type ssh --ssh-key-value "[YOUR_SSH_KEY_VALUE]" --vnet-name [AZURE_VNET] --subnet [SUBNET_NAME] --image [VERDI_IMAGE_NAME] --resource-group [AZURE_RESOURCE_GROUP] --public-ip-per-vm --nsg [NSG_NAME] --eviction-policy delete
    ```

6. Proceed to configure the scaling rules on the Azure Portal
7. If you ever need to reconfigure an existing scale set with a different image, use the following script:

    ```bash
    AZ_RESOURCE_GROUP=[AZURE_RESOURCE_GROUP]
    IMAGE=[VERDI_IMAGE_NAME]
    VMSS=[VMSS_NAME]
    SUBSCRIPTION_ID=[AZURE_SUBSCRIPTION_ID]

    az vmss update --resource-group $AZ_RESOURCE_GROUP --name $VMSS --set virtualMachineProfile.storageProfile.imageReference.id=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$AZ_RESOURCE_GROUP/providers/Microsoft.Compute/images/$IMAGE
    ```

### Post deployment - Manual data download and orbital data scraping

This section is adapted from [hysds/ariamh](https://github.com/hysds/ariamh/wiki/ARIA-Adaptation).

1. Install all necessary HySDS packages (in `sdspkg.tar` format), keep in mind that these packages are not YET publicly distributed, but are proven to work with Azure. Some of them are modified, such as `ariamh`
    - `container-hysds-org_lightweight-jobs:release-20180419` - Basic meta-jobs such as retry, revoke, etc.
    - `container-aria-hysds_qquery:release-20180612` - Performs qquery to check which SLCs to download and automatically runs the sling jobs
    - `container-hysds-org_create_aoi:release-20180306` - Creates an AOI of the region
    - `container-aria-hysds_scihub_acquisition_scraper:release-20180604` - Scrapes data from SciHub or ASF
    - `container-aria-hysds_s1_qc_ingest:release-20180627` - Ingests Sentinel 1 data
    - `container-hysds-org_spyddder-man:release-20180129` - Data discovery, download and extraction. Contains the sling jobs (basically jobs for downloading SLCs)
    - `container-aria-hysds_ariamh:release-20180327` - The ARIA master package
    - If you wish to build your own packages:
        - `sds ci add_job <Github HTTPS link> azure $UID $(id -g)`
        - `-b <branch>` - To build from a specific branch
        - `-k` - To clone with Git token specified in `~/.sds/config`
2. Modify job queues to accelerate certain jobs on Factotum with `~/.sds/files/supervisord.conf.factotum`. Recommended parameters are:
    - `factotum-job_worker-large`: 4
    - `factotum-job_worker-asf_throttled`: 8
3. Run acquisition scraper manually by running the `helpers/1_scrape_scihub.sh` script. Make sure that the version number constant is correct
4. If acquisition scraper is okay, define an AOI using the Tosca web interface and submit a `qquery` job with `helpers/2_qquery.sh`
5. Wait for at least one sling job to complete, and run `cd ~/.sds/rules; sds rules import user_rules.json` to import rules to automatically extract acquisition data. Keep in mind that the extract occurs on Verdi workers. If you don't want this, go to Tosca, click "User Rules" on the top right corner and change the worker type to something like `factotum-large`
6. After all the slings and extract jobs are completed, you can move on to scraping orbit and calibration files with `helpers/3_scrape_s1_orbit.sh`
7. You are now ready to create interferograms!

## Tips / Caveats

- Make sure that Azure is properly configured with `Microsoft.Network`, `Microsoft.Compute` and `Microsoft.Storage` resource providers all enabled
- Triple check the environment variables defined in the `envvars.sh` file before deploying, such as the name of the resource group, the names of the resources to be created etc.
- The scripts are not meant to be run multiple times. It is best to run them only once
- Always perform all tasks on a strong and reliable connection to avoid any potential failures requiring the scripts to be restarted
- The user is required to manually copy and paste certain values from their system or display into the script when necessary. This is to reduce the complexity of the script. Certain more advanced features like JSON parsing is done via piping data into Python
- You may need to switch account subscriptions within your Azure CLI tool using the command `azure account set -s [subscription ID]`
- These scripts use Python's built-in `json` library to process JSON emitted by the `az` tool. The script automatically detects the Python version present on the system
- All SSH/SCP commands are run with `-o StrictHostKeyChecking=no` to skip having to answer `yes` when connecting to the VMs for the first time

## Known issues

### Phase 2 fails with `No module named 'azure.mgmt.compute'` during creation of VM on macOS

This is caused by a faulty version of the `az` tool (namely 2.0.47) installed by Homebrew (if you used Homebrew to install the package). You have to downgrade the tool to 2.0.46 manually with the following commands. This assumes you already have the `az` tool installed.

`$ brew unlink azure-cli`

`$ brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/3894a0d2095f48136ce1af5ebd5ba42dd38f1dac/Formula/azure-cli.rb`

### `yum -y update` hangs during Phase 2

Symptoms: During the provisioning of the base VM in phase 2, a `yum -y update` command causes the base VM to be unresponsive. There may also be a `ssh_exchange_identification: read: Connection reset by peer` message returned if one attempts to SSH into the VM.

Reason: The `yum -y update` command is CPU intensive, and for some reason, the deprovisioning commands are run in parallel with the package updater, causing the user to be unable to SSH back into the machine.

Solution: The `yum -y update` command has been moved from phase 2 to phase 4. The deprovisioning commands are explicitly run on another SSH session right after the installation of necessary yum packages.

## Contributing

If you encounter any issues with the script, please do not hesitate to open an issue on this repo.