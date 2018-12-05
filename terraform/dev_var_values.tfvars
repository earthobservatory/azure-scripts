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

# Verdi Image Creator VM
verdi_vm_name               = "VerdiImageCreatorTerra"
verdi_vm_ip                 = "VerdiVMIPTerra"
vmss_instance_type          = "Standard_F4s_v2"
vmss_group_name             = "vmssdevterra"

# SSH keys for the VMs
ssh_key_dir                 = "/Developer/EOS Internship/Azure Keys/hysdsdev"
ssh_key_pub_dir             = "/Developer/EOS Internship/Azure Keys/hysdsdev.pub"

# VM Parameters
mozart_instance             = "MozartVMTerra"
mozart_instance_type        = "Standard_E4_v3"
metrics_instance            = "MetricsVMTerra"
metrics_instance_type       = "Standard_E4_v3"
grq_instance                = "GRQVMTerra"
grq_instance_type           = "Standard_E4_v3"
factotum_instance           = "FactotumVMTerra"
factotum_instance_type      = "Standard_F8s_v2"
factotum_docker_disk        = "FactotumDockerDiskTerra"
ci_instance                 = "CIVMTerra"
ci_instance_type            = "Standard_D4_v3"
