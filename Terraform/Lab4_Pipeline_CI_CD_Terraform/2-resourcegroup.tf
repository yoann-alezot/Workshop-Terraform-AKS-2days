#                                   _____                                        _____                       
#      /\                          |  __ \                                      / ____|                      
#     /  \    _____   _ _ __ ___   | |__) |___  ___  ___  _   _ _ __ ___ ___   | |  __ _ __ ___  _   _ _ __  
#    / /\ \  |_  / | | | '__/ _ \  |  _  // _ \/ __|/ _ \| | | | '__/ __/ _ \  | | |_ | '__/ _ \| | | | '_ \ 
#   / ____ \  / /| |_| | | |  __/  | | \ \  __/\__ \ (_) | |_| | | | (_|  __/  | |__| | | | (_) | |_| | |_) |
#  /_/    \_\/___|\__,_|_|  \___|  |_|  \_\___||___/\___/ \__,_|_|  \___\___|   \_____|_|  \___/ \__,_| .__/ 
#                                                                                                     | |    
#                                                                                                     |_|    

# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azure_resource_group" "RG-Name"{
  name = "${join(["asiweursgscb",var.environnement,"01"])}"
  location = var.azureRegion
}

resource "azurerm_storage_account" "Terra-Storage-Backend" {
  name                      = "${join(["asiweustoscb",var.environnement,"1z"])}"
  resource_group_name       = azurerm_resource_group.Terra_tfbackend_rg.name
  location                  = azurerm_resource_group.Terra_tfbackend_rg.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true

  tags = {
    environment = "lab"
  }
}

##################################################################################################################
resource "azure_resource_group" "RG-DEV"{
  name = "asiweursgscbd01"
  location = var.azureRegion
}

resource "azure_resource_group" "RG-PROD"{
  name = "asiweursgscbp01"
  location = var.azureRegion
}

resource "azurerm_storage_account" "Terra-Storage-Backend" {
  name                      = "${var.environnement == "PROD" ? "asiweustoscbp1z" : "asiweustoscbd1z"}"
  resource_group_name       = "${var.environnement == "PROD" ? azure_resource_group.RG-PROD.name : azure_resource_group.RG-DEV.name}"
  location                  = azurerm_resource_group.Terra_tfbackend_rg.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true

  tags = {
    environment = "lab"
  }
}


resource "azurerm_storage_container" "Terra-Container-Storage" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.Terra-Storage-Backend.name
  container_access_type = "private"
}
