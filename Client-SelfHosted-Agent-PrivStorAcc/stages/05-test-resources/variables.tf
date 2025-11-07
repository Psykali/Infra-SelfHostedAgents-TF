variable "client_name" {
  description = "Name of the client"
  type        = string
  default     = "client"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "France Central"
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
  default     = "bseclientstfrancecentral001"
}