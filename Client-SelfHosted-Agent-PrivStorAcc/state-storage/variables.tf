variable "location" {
  description = "Azure region for storage account"
  type        = string
  default     = "France Central"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "statestoragetfdevops"
}