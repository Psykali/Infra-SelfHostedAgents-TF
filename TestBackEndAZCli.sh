# 1 - Add your IP adresse to have a visiual access to the storage account 
az storage account network-rule add \
  --resource-group "client-tfstate-storage-rg" \
  --account-name "clienttfprivstacc" \
  --ip-address "PublicIP"

echo "Added IP: $MY_IP to storage account firewall"

# 2- Check current network rules
az storage account show \
  --resource-group "client-tfstate-storage-rg" \
  --name "clienttfprivstacc" \
  --query "{networkRuleSet:networkRuleSet}" --output table

# 3- Test connectivity
az storage container list \
  --account-name "clienttfprivstacc" \
  --auth-mode login

# 4- Remove the IP rule 
az storage account network-rule remove \
  --resource-group "client-tfstate-storage-rg" \
  --account-name "clienttfprivstacc" \
  --ip-address "PublicIP"