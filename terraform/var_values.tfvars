# Basic network setup
location                    = "Southeast Asia"
resource_group              = "HySDS_Dev_Terra"
virtual_net                 = "HySDS_VNet_Dev_Terra"
subnet                      = "HySDS_Subnet_Dev_Terra"
network_security_group      = "HySDS_NSG_Dev_Terra"

# Network interface cards
nic_mozart                  = "MozartNIC_Dev_Terra"
nic_metrics                 = "MetricsNIC_Dev_Terra"
nic_grq                     = "GRQNIC_Dev_Terra"
nic_factotum                = "FactotumNIC_Dev_Terra"
nic_ci                      = "CINIC_Dev_Terra"

# Name of the Public IP instances
publicip_mozart             = "MozartPubIP_Dev_Terra"
publicip_metrics            = "MetricsPubIP_Dev_Terra"
publicip_grq                = "GRQPubIP_Dev_Terra"
publicip_factotum           = "FactotumPubIP_Dev_Terra"
publicip_ci                 = "CIPubIP_Dev_Terra"

# Insights/Telemetry
insights                    = "HySDS_Dev_Insights_Terra"

# Storage
storage_account_name        = "hysdsdevterra"
storage_code_container      = "code"
storage_dataset_container   = "dataset"

# Base VM
base_vm_name                = "BaseImageDevTerra"
base_vm_ip                  = "BaseVMIPTerra"
base_image_name             = "HySDS_BaseImage_CentOS75_Dev_Terra"

# Authentication to the VMs
ssh_key_name                = "hysds-dev"
ssh_key_dir                 = "/Developer/EOS Internship/Azure Keys/hysds-dev"
ssh_key_pub_dir             = "/Developer/EOS Internship/Azure Keys/hysds-dev.pub"

# VM Parameters
mozart_instance             = "MozartVMTerra"
metrics_instance            = "MetricsVMTerra"
grq_instance                = "GRQVMTerra"
factotum_instance           = "FactotumVMTerra"
ci_instance                 = "CIVMTerra"
