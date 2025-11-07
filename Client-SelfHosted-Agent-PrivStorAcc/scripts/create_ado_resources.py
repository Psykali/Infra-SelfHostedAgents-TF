#!/usr/bin/env python3
"""
Script to create Azure DevOps PAT and agent pool via Azure DevOps REST API
"""
import requests
import json
import sys
import os
from datetime import datetime, timedelta

def create_pat(organization, project, client_name, pat_token):
    """Create Personal Access Token for the agent"""
    
    # This is a simplified version - in production, use Azure DevOps REST API
    # or Azure CLI to create PAT programmatically
    
    pat_name = f"BSE-{client_name}-PAT-{datetime.now().strftime('%Y%m%d')}"
    
    print(f"""
    Manual steps required to create PAT:
    
    1. Go to: https://dev.azure.com/{organization}/_usersSettings/tokens
    2. Create new Personal Access Token with name: {pat_name}
    3. Set expiration as needed (recommended: 1 year)
    4. Scopes required:
       - Agent Pools (Read & manage)
       - Deployment group (Read & manage) 
       - Service Connections (Read & manage)
       - Project and Team (Read)
    5. Copy the generated PAT and use it for agent configuration
    
    Alternatively, use Azure CLI:
    az devops project create --name {project} --organization https://dev.azure.com/{organization}
    """)
    
    return pat_name

def main():
    if len(sys.argv) != 4:
        print("Usage: python create_ado_resources.py <organization> <project> <client_name>")
        sys.exit(1)
    
    organization = sys.argv[1]
    project = sys.argv[2]
    client_name = sys.argv[3]
    
    # Get PAT token from environment or prompt
    pat_token = os.getenv('AZURE_DEVOPS_PAT')
    if not pat_token:
        print("Please set AZURE_DEVOPS_PAT environment variable")
        sys.exit(1)
    
    create_pat(organization, project, client_name, pat_token)

if __name__ == "__main__":
    main()