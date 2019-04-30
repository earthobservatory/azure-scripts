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
base_vm_type                = "Standard_B2s"

# Verdi Image Creator VM
verdi_vm_name               = "VerdiImageCreatorProdTerra"
verdi_vm_ip                 = "VerdiVMIPProdTerra"
vmss_instance_type          = "Standard_D32s_v3"
vmss_group_name             = "vmssprodterra"

# SSH keys for the VMs
ssh_key_dir                 = "/Developer/EOS Internship/Azure Keys/hysdsprod"
ssh_key_pub_dir             = "/Developer/EOS Internship/Azure Keys/hysdsprod.pub"

# VM Parameters
puppet_branch_version       = "azure-beta1"
mozart_instance             = "MozartVMProdTerra"
mozart_instance_type        = "Standard_E8s_v3"
metrics_instance            = "MetricsVMProdTerra"
metrics_instance_type       = "Standard_E8s_v3"
grq_instance                = "GRQVMProdTerra"
grq_instance_type           = "Standard_E16s_v3"
factotum_instance           = "FactotumVMProdTerra"
factotum_instance_type      = "Standard_F32s_v2"
ci_instance                 = "CIVMProdTerra"
ci_instance_type            = "Standard_F4s"
