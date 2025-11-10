locals {
  common_tags = {
    Client        = "BSE"
    Environment   = "Prod"
    CreatedBy     = "SKA"
    Purpose       = "Test DevOps SelfHosted Agents"
    Project       = "Forge DevOps"
#    CostCenter    = ""
#    BusinessUnit  = ""
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
    Terraform     = "true"
    ManagedBy     = "terraform"
  }

  # Optional: Environment-specific tags
  environment_tags = {
    Dev = {
      Criticality = "low"
      AutoShutdown = "true"
    }
    QAL = {
      Criticality = "medium"
      AutoShutdown = "false"
    }
    Prod = {
      Criticality = "high"
      AutoShutdown = "false"
    }
  }
}