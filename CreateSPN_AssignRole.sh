#!/bin/bash

# Variables
SUBSCRIPTION_ID="client-subscription-id"
SPN_NAME="client-devops-agent-spn"
ROLE_NAME="Contributor"

# Login to Azure (if not already logged in)
az login

# Set the active subscription
az account set --subscription $SUBSCRIPTION_ID

# Create Service Principal
echo "Creating Service Principal..."
SPN_JSON=$(az ad sp create-for-rbac --name $SPN_NAME --role $ROLE_NAME --scopes /subscriptions/$SUBSCRIPTION_ID --years 1 --output json)

# Extract credentials
APP_ID=$(echo $SPN_JSON | jq -r '.appId')
PASSWORD=$(echo $SPN_JSON | jq -r '.password')
TENANT_ID=$(echo $SPN_JSON | jq -r '.tenant')

# Output the credentials
echo "Service Principal created successfully:"
echo "AppId: $APP_ID"
echo "Password: $PASSWORD"
echo "Tenant: $TENANT_ID"
echo "Subscription: $SUBSCRIPTION_ID"

# Save to file for later use
echo "AZURE_APP_ID=$APP_ID" > spn-credentials.env
echo "AZURE_CLIENT_SECRET=$PASSWORD" >> spn-credentials.env
echo "AZURE_TENANT_ID=$TENANT_ID" >> spn-credentials.env
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID" >> spn-credentials.env

echo "Credentials saved to spn-credentials.env"