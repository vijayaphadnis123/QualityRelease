provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  features {}
}

terraform {

  backend "azurerm" {
    storage_account_name = "udaqualityrelease"
    container_name       =  "tfstate"
    key                  = "prod.terraform.tfstate"
    access_key           = "2J5PXy90L6HZdHGIPqxdNsnZ1y/5XHkVWVPBDuh0VvqAaqP1JFTB2Ce3NYlIU1cXe3IFWLWoB0sqfti+SHa6oQ=="
   
  }

}

module "resource_group" {
  source               = "./modules/resource_group"
  resource_group       = "${var.resource_group}"
  location             = "${var.location}"
}
module "network" {
  source               = "./modules/network"
  address_space        = "${var.address_space}"
  location             = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  application_type     = "${var.application_type}"
  resource_type        = "NET"
  resource_group       = "${module.resource_group.resource_group_name}"
  address_prefix_test  = "${var.address_prefix_test}"
 // network_interface_name = "${module.network.network_interface_name}"
}

module "nsg-test" {
  source           = "./modules/networksecuritygroup"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "NSG"
  resource_group   = "${module.resource_group.resource_group_name}"
  subnet_id        = "${module.network.subnet_id_test}"
  address_prefix_test = "10.5.1.0/24"
}
module "appservice" {
  source           = "./modules/appservice"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "AppService"
  resource_group   = "${module.resource_group.resource_group_name}"
}
module "publicip" {
  source           = "./modules/publicip"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "publicip"
  resource_group   = "${module.resource_group.resource_group_name}"
}

resource "azurerm_network_interface" "test" {
	
	name					        = "${var.application_type}-nwif"
	resource_group_name 	= "${module.resource_group.resource_group_name}"
  location 				      = "${var.location}"

	ip_configuration {
		name 							= "My-IpConfig"
		subnet_id    			= "${module.network.subnet_id_test}"
    private_ip_address_allocation = "Dynamic"
	}
}



resource "azurerm_linux_virtual_machine" "example" {
	
	name 							        = "${var.name}"
	resource_group_name 			= "${module.resource_group.resource_group_name}"
	location 						      = "${var.location}"
  network_interface_ids     = [azurerm_network_interface.test.id]
 	size                   		= "${var.size}" 
  admin_username            = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }


	#disable_password_authentication = false	
	source_image_reference {

    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.sourceVersion}"
  }
 
	os_disk {
		storage_account_type 	= "Standard_LRS"
		caching		     		= "ReadWrite" 
	}


}