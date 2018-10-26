# Phase 1: Creation of network and storage assets

###############################################################################
# Resource Group
###############################################################################
resource "azurerm_resource_group" "hysds" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

output "Resource Group / AZURE_RESOURCE_GROUP" {
  value = "${var.resource_group}"
}

###############################################################################
# Virtual Network
###############################################################################
resource "azurerm_virtual_network" "hysds" {
  name                = "${var.virtual_net}"
  address_space       = ["10.1.0.0/16"]
  location            = "${azurerm_resource_group.hysds.location}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
}

resource "azurerm_subnet" "hysds" {
  name                 = "${var.subnet}"
  resource_group_name  = "${azurerm_resource_group.hysds.name}"
  virtual_network_name = "${azurerm_virtual_network.hysds.name}"
  address_prefix       = "10.1.1.0/24"
}

###############################################################################
# Network Security Group and Rules
###############################################################################
resource "azurerm_network_security_group" "hysds" {
    name                = "${var.network_security_group}"
    resource_group_name = "${azurerm_resource_group.hysds.name}"
    location            = "${azurerm_resource_group.hysds.location}"

    security_rule {
        name        = "SSHAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1000"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "22"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "HTTPAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1100"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "80"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "HTTPSAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1200"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "443"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "HTTPAltAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1300"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "8080"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "QueueAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1400"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "15672"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "CeleryAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1500"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "5555"
        destination_address_prefix = "*"
    }

    security_rule {
        name        = "ElasticSearchAccess"
        description = ""
        protocol    = "Tcp"
        access      = "Allow"
        priority    = "1600"
        direction   = "Inbound"

        source_address_prefix  = "Internet"
        source_port_range      = "*"
        destination_port_range = "9200"
        destination_address_prefix = "*"
    }
}

###############################################################################
# Public IPs
###############################################################################
resource "azurerm_public_ip" "mozart" {
  name                         = "${var.publicip_mozart}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.mozart_instance)}"
  public_ip_address_allocation = "static"
}
output "Mozart public IP / MOZART_PUB_IP" {
  value = "${azurerm_public_ip.mozart.ip_address}"
}

resource "azurerm_public_ip" "metrics" {
  name                         = "${var.publicip_metrics}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.metrics_instance)}"
  public_ip_address_allocation = "static"
}
output "Metrics public IP / METRICS_PUB_IP" {
  value = "${azurerm_public_ip.metrics.ip_address}"
}

resource "azurerm_public_ip" "grq" {
  name                         = "${var.publicip_grq}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.grq_instance)}"
  public_ip_address_allocation = "static"
}
output "GRQ public IP / GRQ_PUB_IP" {
  value = "${azurerm_public_ip.grq.ip_address}"
}

resource "azurerm_public_ip" "factotum" {
  name                         = "${var.publicip_factotum}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.factotum_instance)}"
  public_ip_address_allocation = "static"
}
output "Factotum public IP / FACTOTUM_PUB_IP" {
  value = "${azurerm_public_ip.factotum.ip_address}"
}

resource "azurerm_public_ip" "ci" {
  name                         = "${var.publicip_ci}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.ci_instance)}"
  public_ip_address_allocation = "static"
}
output "CI public IP / CI_PUB_IP" {
  value = "${azurerm_public_ip.ci.ip_address}"
}

###############################################################################
# Network Interface Cards
###############################################################################
resource "azurerm_network_interface" "mozart" {
  name = "${var.nic_mozart}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  location = "${azurerm_resource_group.hysds.location}"
  network_security_group_id = "${azurerm_network_security_group.hysds.id}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name = "${var.nic_mozart}"
    subnet_id = "${azurerm_subnet.hysds.id}"
    private_ip_address = "10.1.1.5"
    private_ip_address_allocation = "static"
    public_ip_address_id = "${azurerm_public_ip.mozart.id}"
  }
}
output "Mozart private IP / MOZART_PVT_IP" {
  value = "${azurerm_network_interface.mozart.ip_configuration.0.private_ip_address}"
}

resource "azurerm_network_interface" "metrics" {
  name = "${var.nic_metrics}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  location = "${azurerm_resource_group.hysds.location}"
  network_security_group_id = "${azurerm_network_security_group.hysds.id}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name = "${var.nic_metrics}"
    subnet_id = "${azurerm_subnet.hysds.id}"
    private_ip_address = "10.1.1.6"
    private_ip_address_allocation = "static"
    public_ip_address_id = "${azurerm_public_ip.metrics.id}"
  }
}
output "Metrics private IP / METRICS_PVT_IP" {
  value = "${azurerm_network_interface.metrics.ip_configuration.0.private_ip_address}"
}
resource "azurerm_network_interface" "grq" {
  name = "${var.nic_grq}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  location = "${azurerm_resource_group.hysds.location}"
  network_security_group_id = "${azurerm_network_security_group.hysds.id}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name = "${var.nic_grq}"
    subnet_id = "${azurerm_subnet.hysds.id}"
    private_ip_address = "10.1.1.7"
    private_ip_address_allocation = "static"
    public_ip_address_id = "${azurerm_public_ip.grq.id}"
  }
}
output "GRQ private IP / GRQ_PVT_IP" {
  value = "${azurerm_network_interface.grq.ip_configuration.0.private_ip_address}"
}

resource "azurerm_network_interface" "factotum" {
  name = "${var.nic_factotum}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  location = "${azurerm_resource_group.hysds.location}"
  network_security_group_id = "${azurerm_network_security_group.hysds.id}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name = "${var.nic_factotum}"
    subnet_id = "${azurerm_subnet.hysds.id}"
    private_ip_address = "10.1.1.8"
    private_ip_address_allocation = "static"
    public_ip_address_id = "${azurerm_public_ip.factotum.id}"
  }
}
output "Factotum private IP / FACTOTUM_PVT_IP" {
  value = "${azurerm_network_interface.factotum.ip_configuration.0.private_ip_address}"
}

resource "azurerm_network_interface" "ci" {
  name = "${var.nic_ci}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  location = "${azurerm_resource_group.hysds.location}"
  network_security_group_id = "${azurerm_network_security_group.hysds.id}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name = "${var.nic_ci}"
    subnet_id = "${azurerm_subnet.hysds.id}"
    private_ip_address = "10.1.1.9"
    private_ip_address_allocation = "static"
    public_ip_address_id = "${azurerm_public_ip.ci.id}"
  }
}
output "CI private IP / CI_PVT_IP" {
  value = "${azurerm_network_interface.ci.ip_configuration.0.private_ip_address}"
}

###############################################################################
# Instrumentation
###############################################################################
resource "azurerm_application_insights" "hysds" {
  name                = "${var.insights}"
  location            = "${azurerm_resource_group.hysds.location}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"
  application_type    = "Web"
}

output "Azure Instrumentation Key / AZURE_TELEMETRY_KEY" {
  value = "${azurerm_application_insights.hysds.instrumentation_key}"
}

###############################################################################
# Storage
###############################################################################
resource "azurerm_storage_account" "hysds" {
  name                      = "${var.storage_account_name}"
  resource_group_name       = "${azurerm_resource_group.hysds.name}"
  location                  = "${azurerm_resource_group.hysds.location}"
  account_tier              = "Standard"
  access_tier               = "Hot"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
}

output "Azure Storage Account Name / AZURE_STORAGE_ACCOUNT_NAME" {
  value = "${var.storage_account_name}"
}

output "Azure Storage Account Primary Key / AZURE_STORAGE_ACCOUNT_KEY" {
  value = "${azurerm_storage_account.hysds.primary_access_key}"
}

resource "azurerm_storage_container" "code" {
  name                  = "${var.storage_code_container}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  storage_account_name  = "${azurerm_storage_account.hysds.name}"
  container_access_type = "container"
}

resource "azurerm_storage_container" "dataset" {
  name                  = "${var.storage_dataset_container}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  storage_account_name  = "${azurerm_storage_account.hysds.name}"
  container_access_type = "container"
}

output "Website Endpoint / AZURE_WEBSITE_ENDPOINT and AZURE_ENDPOINT" {
  value = "${var.storage_account_name}.blob.core.windows.net"
}

output "Verdi image location / VERDI_PRIMER_IMAGE" {
  value = "azure://${var.storage_account_name}.blob.core.windows.net/hysds-verdi-latest.tar.gz"
}
