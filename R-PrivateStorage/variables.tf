# Variables
variable "private_storage_name" {
  description = "Name of the storage account"
  default     = "clienttfprivstacc"
}

variable "storage_rg_name" {
  description = "Name of the resource group for storage"
  default     = "client-tfstate-storage-rg"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "tfstate_container_name" {
  description = "tfstate_container_name"
  default     = "client-tfstate"
}

variable "private_endpoint_name" {
  description = "Private Endpoint Name"
  default     = "client-storage-private-endpoint"
}

variable "private_endpoint_connection_name" {
  description = "Private Endpoint Connection Name"
  default     = "client-storage-private-connection"
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet for private endpoint"
  default     = "private-endpoint-subnet"
}