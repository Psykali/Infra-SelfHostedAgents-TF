#!/usr/bin/env python3
"""
Script to create Azure DevOps PAT and agent pool via Azure DevOps REST API
"""
import requests
import json
import sys
import os
import base64
from datetime import datetime, timedelta

class AzureDevOpsManager:
    def __init__(self, organization, pat_token):
        self.organization = organization
        self.pat_token = pat_token
        self.base_url = f"https://dev.azure.com/{organization}"
        self.headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Basic {base64.b64encode(f":{pat_token}".encode()).decode()}'
        }

    def create_agent_pool(self, pool_name, pool_id=None):
        """Create agent pool using REST API"""
        url = f"{self.base_url}/_apis/distributedtask/pools?api-version=6.0"
        
        payload = {
            "name": pool_name,
            "autoProvision": False,
            "autoUpdate": True
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=payload)
            if response.status_code in [200, 201]:
                print(f"✓ Agent pool '{pool_name}' created successfully")
                return response.json()
            elif response.status_code == 409:
                print(f"ℹ Agent pool '{pool_name}' already exists")
                # Try to get existing pool
                return self.get_agent_pool(pool_name)
            else:
                print(f"✗ Failed to create agent pool: {response.text}")
                return None
        except Exception as e:
            print(f"✗ Error creating agent pool: {e}")
            return None

    def get_agent_pool(self, pool_name):
        """Get existing agent pool"""
        url = f"{self.base_url}/_apis/distributedtask/pools?api-version=6.0"
        
        try:
            response = requests.get(url, headers=self.headers)
            if response.status_code == 200:
                pools = response.json().get('value', [])
                for pool in pools:
                    if pool['name'] == pool_name:
                        print(f"✓ Found existing agent pool: {pool_name}")
                        return pool
            return None
        except Exception as e:
            print(f"✗ Error getting agent pool: {e}")
            return None

    def create_pat(self, display_name, scope="AgentPools"):
        """Create Personal Access Token (Note: This requires additional permissions)"""
        # Note: PAT creation via API requires special permissions
        # This is a placeholder for the actual implementation
        pat_name = f"BSE-{display_name}-PAT-{datetime.now().strftime('%Y%m%d')}"
        
        print(f"""
        PAT Creation Instructions for {display_name}:
        
        1. Go to: https://dev.azure.com/{self.organization}/_usersSettings/tokens
        2. Create new Personal Access Token with name: {pat_name}
        3. Set expiration as needed (recommended: 1 year)
        4. Required Scopes:
           - Agent Pools (Read & manage)
           - Deployment Groups (Read & manage)
           - Service Connections (Read, query & manage)
           - Project and Team (Read)
        5. Copy the generated PAT and store it securely
        
        Alternatively, use Azure CLI:
        az devops login --organization https://dev.azure.com/{self.organization}
        """)
        
        return pat_name

def main():
    if len(sys.argv) != 5:
        print("Usage: python create_ado_resources.py <organization> <project> <client_name> <admin_pat>")
        sys.exit(1)
    
    organization = sys.argv[1]
    project = sys.argv[2]
    client_name = sys.argv[3]
    admin_pat = sys.argv[4]
    
    # Initialize Azure DevOps manager
    ado_manager = AzureDevOpsManager(organization, admin_pat)
    
    # Create agent pool
    pool_name = f"BSE-{client_name}-Pool"
    print(f"Creating agent pool: {pool_name}")
    agent_pool = ado_manager.create_agent_pool(pool_name)
    
    if agent_pool:
        print(f"Agent Pool ID: {agent_pool.get('id')}")
        print(f"Agent Pool Name: {agent_pool.get('name')}")
    else:
        print("Failed to create or retrieve agent pool")
        sys.exit(1)
    
    # Provide PAT creation instructions
    print("\n" + "="*50)
    ado_manager.create_pat(client_name)
    print("="*50)
    
    print(f"""
    Configuration Summary:
    - Organization: {organization}
    - Project: {project}
    - Client: {client_name}
    - Agent Pool: {pool_name}
    - Agent Pool ID: {agent_pool.get('id')}
    
    Next Steps:
    1. Create the PAT using the instructions above
    2. Use the PAT to configure the self-hosted agent
    3. The agent will automatically register with pool: {pool_name}
    """)

if __name__ == "__main__":
    main()