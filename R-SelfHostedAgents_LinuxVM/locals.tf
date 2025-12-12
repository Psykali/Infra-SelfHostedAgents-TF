### Tages 

locals {
  common_tags = {
    Client        = "BSE"
    Environment   = "Prod"     ### Choose between (Dev, QAL & Prod)
    Criticality   = "High"     ### Choose between (Low, Medium & High)
    CreatedBy     = "SKA"      ###  BSE Name Code
    Purpose       = "Test DevOps SelfHosted Agents"
    Project       = "Forge DevOps"
#    CostCenter    = ""
#    BusinessUnit  = ""
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
    Terraform     = "true"
    ManagedBy     = "terraform"
  }
}