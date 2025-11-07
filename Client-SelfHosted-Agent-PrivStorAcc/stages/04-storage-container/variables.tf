variable "client_name" {
  description = "Name of the client"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "France Central"
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}