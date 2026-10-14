resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "dev"
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = lower(substr(replace("${var.project_name}${random_string.suffix.result}", "-", ""), 0, 24))
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "azurerm_container_registry" "acr" {
  name                = substr(replace(lower("${var.project_name}${random_string.suffix.result}"), "-", ""), 0, 50)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}
