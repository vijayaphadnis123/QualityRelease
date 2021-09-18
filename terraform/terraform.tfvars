# Azure subscription vars
subscription_id = ""
client_id = ""
client_secret = ""
tenant_id = ""

# Resource Group/Location
location = "Central US"
resource_group = "MyResGroup1"
application_type = "Infra-CICD-Autotest"


# Network
virtual_network_name = "myVirtualNetwork"
address_space = ["10.5.0.0/16"]
address_prefix_test = "10.5.1.0/24"

#VM

size =  "Standard_B1s"
name =  "MyVM"
publisher = "Canonical"
offer     = "UbuntuServer"
sku       = "18.04-LTS"
sourceVersion   = "latest"

