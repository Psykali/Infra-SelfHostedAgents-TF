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
  default     = "bseclientstfr001"
}

variable "deployment_ip" {
  description = "IP address of the deployment agent to allow temporary access"
  type        = string
  default     = "98.66.233.160"
}