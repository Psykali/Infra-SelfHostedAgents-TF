variable "client_name" {
  description = "Name of the client"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "France Central"
}

variable "environment" {
  description = "Environment (dev, prod, etc)"
  type        = string
  default     = "prod"
}