# Basic network setup
location                    = "Southeast Asia"
resource_group              = "HySDS_Prod_Terra"
virtual_net                 = "HySDS_VNet_Prod_Terra"
subnet                      = "HySDS_Subnet_Prod_Terra"
network_security_group      = "HySDS_NSG_Prod_Terra"

# Network interface cards
nic_mozart                  = "MozartNIC_Prod_Terra"
nic_metrics                 = "MetricsNIC_Prod_Terra"
nic_grq                     = "GRQNIC_Prod_Terra"
nic_factotum                = "FactotumNIC_Prod_Terra"
nic_ci                      = "CINIC_Prod_Terra"

# Name of the Public IP instances
publicip_mozart             = "MozartPubIP_Prod_Terra"
publicip_metrics            = "MetricsPubIP_Prod_Terra"
publicip_grq                = "GRQPubIP_Prod_Terra"
publicip_factotum           = "FactotumPubIP_Prod_Terra"
publicip_ci                 = "CIPubIP_Prod_Terra"

# Insights/Telemetry
insights                    = "HySDS_Prod_Insights_Terra"

# Storage
storage_account_name        = "hysdsprodterra"
storage_code_container      = "code"
storage_dataset_container   = "dataset"

# Base VM
base_vm_name                = "BaseImageProdTerra"
base_vm_ip                  = "BaseVMIPProdTerra"
base_image_name             = "HySDS_BaseImage_CentOS75_Prod_Terra"

# Verdi Image Creator VM
verdi_vm_name               = "VerdiImageCreatorProdTerra"
verdi_vm_ip                 = "VerdiVMIPProdTerra"
vmss_group_name             = "vmssprodterra"

# SSH keys for the VMs
ssh_key_dir                 = "/Developer/EOS Internship/Azure Keys/hysdsdev"
ssh_key_pub_dir             = "/Developer/EOS Internship/Azure Keys/hysdsdev.pub"

# VM Parameters
mozart_instance             = "MozartVMProdTerra"
metrics_instance            = "MetricsVMProdTerra"
grq_instance                = "GRQVMProdTerra"
factotum_docker_disk        = "FactotumDockerDiskProdTerra"
factotum_instance           = "FactotumVMProdTerra"
ci_instance                 = "CIVMProdTerra"
