# Terraform Deployment Scripts

The Terraform scripts provides a "versionable" way to write Infrastructure as Code (IAC), and provides a quick way to deploy, and to alter the architecture without having to delete the entire resource group (only applies under certain scenarios). The Terraform version is written in a hybrid manner: while most of the infrastructure is described using Terraform's `.tf` files, there are a few shell scripts that are run by Terraform using [null resources](https://www.terraform.io/docs/provisioners/null_resource.html) that makes Terraform more flexible.

## Files

| Filename | Description |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `phase1.tf` | Terraform file describing all network and storage assets, such as virtual networks, storage accounts and containers, IP address allocation and so on |
| `phase3.tf` | Terraform file describing the major static components of HySDS, namely the Mozart, Metrics, GRQ, Factotum, and CI virtual machines |
| `phase4.tf` | Terraform file describing the Verdi base image creator VM |
| `generalize_base_image.sh` | A helper shell script that generalizes the base image, called by a `null_resource` in `phase2.tf` to automatically deallocate and generalize the base image without user intervention |
| `configure_instances.sh` | A shell script that asynchronously configures the major components of HySDS. It is called by a `null_resource` in `phase3.tf` |
| `configure_verdi_base.sh` | A shell script that asynchronously configures the Verdi base image creator VM. It is called by a `null_resource` in `phase4.tf` |
| `switch_dev_prod.sh` | A small helper shell script that allows the operator to switch between development and production environments if they have more than one `.tfstate` file |

## Usage

### 1 - Getting Terraform

Download and install Terraform on your machine (preferably a UNIX-like system such as a Mac or a Linux machine) with [this link](https://www.terraform.io/downloads.html).

### 2 - Creating the base image manually

Edit and run `create_base_vm.sh`. Follow its instructions to semi-automatically create the base VM. The base VM must be created before running Terraform scripts as the `tfvars` configuration files require the name of the image created from the base VM. The reason for creating the base VM separately and manually is to decouple image creation logic from the  cluster creation logic, preventing a case whereby altering the base VM's parameters in some way automatically forces Terraform to attempt to recreate the entire cluster.

### 3 - Configuration

Copy and edit the`prod_var_values.tfvars` file to suit your configuration.

### 4 - Initialising Terraform

Run `terraform init` in order for Terraform to download the appropriate tools for working with Azure.

### 5 - Apply changes

Run `terraform apply -var-file=<your tfvars file>`, verify that the parameters are correct and type `yes` to apply the changes.

### 6A - Post deployment

Once everything is done, run `az ad sp create-for-rbac --sdk-auth` in your command line to create an Active Directory application and retrieve the parameters necessary for `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET_KEY`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID` when you're configuring the HySDS cluster through `sds configure`. Keep in mind that running this command will create a service principal with a root-level scope.

### 6B - Post post deplotment (of Verdi)

The Verdi instance needs to configured further manually and imaged so that the Virtual Machine Scale Sets can automatically spin up with the correct image.

1. Push Azure credentials from Mozart to Verdi manually with the script below, making sure to change the variables to the correct values:

        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$MOZART_IP" << EOSSH
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/azure_credentials.json ops@$VERDI_IP:~/.azure
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/config ops@$VERDI_IP:~/.azure
        EOSSH

2. On Mozart, update Verdi's virtualenv, configuration files and software with `sdscli`

        # replace VERDI_PVT_IP, VERDI_PUB_IP and VERDI_FQDN in ~/.sds/config with actual values
        vi ~/.sds/config
        sds update verdi -f

3. SSH into the Verdi machine and install additional packages required for Azure to function correctly

        source /home/ops/verdi/bin/activate
        pip install azure msrest msrestazure ConfigParser

4. Deprovision the Verdi base VM to make it suitable for creating images. **WARNING: Do not run this command on any other machine than the Verdi VM! Please double check the VM you are running this command on**

        sudo waagent -deprovision

5. Close the connection and create the Verdi image using Azure CLI on a separate machine

        az vm deallocate --resource-group "$AZ_RESOURCE_GROUP" --name "$BASE_VM_NAME"
        az vm generalize --resource-group "$AZ_RESOURCE_GROUP" --name "$BASE_VM_NAME"
        az image create --resource-group "$AZ_RESOURCE_GROUP" --name "$VERDI_IMAGE_NAME" --source "$BASE_VM_NAME"

## Redeploying a failed asset

If at any point, the deployment of an asset is interrupted by, say, connection issues, you can redeploy the failed asset by "tainting" the asset and allowing Terraform to recreate it.

For example, if you want to redeploy the Mozart instance, simply issue the command `terraform taint azurerm_virtual_machine.mozart` and Terraform will destroy and recreate the instance for you. Keep in mind that you will have to set up that instance manually afterwards.

Another use of using `terraform taint` is to recreate the Verdi image when a new CentOS version is released or when there are too many catch-up updates during autoscale provisioning (as the autoscale workers automatically update themselves before actually running any jobs).

## Deficiencies of Terraform

Terraform in essence is a cloud architecture orchestration tool; a declarative language, rather than procedural (contrasting with the shell version). This means that it only concerns itself with assets and dependencies, not the state of the asset themselves. Terraform can only spin up VMs, and cannot alter their power states and so on. In the `.tf` files, you may notice `null_resource`s being created. Null resources are resources not tied to an actual cloud resource, but rather to add a bit of procedural logic in an otherwise declarative environment. For example, the configuration of the Verdi base VM is done through an external shell script through a `null_resource`, not through Terraform's own system because Terraform does not handle these tasks.

These null resources are not automatically destroyed, and must be destroyed with the rest of the system when running `terraform destroy -var-file=var_values.tfvars`
