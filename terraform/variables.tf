variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-devsecops-demo"
}

variable "project_name" {
  description = "Project prefix used in naming resources"
  type        = string
  default     = "devsecopsdemo"
}
