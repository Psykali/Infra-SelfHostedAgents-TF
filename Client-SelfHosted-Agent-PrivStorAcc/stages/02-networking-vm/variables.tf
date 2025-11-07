variable "client_name" {
  description = "Name of the client"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "France Central"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "BseSelfAgent"
}

variable "admin_password" {
  description = "Admin password for VM"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "storage_account_id" {
  description = "Storage account ID for private endpoint"
  type        = string
}