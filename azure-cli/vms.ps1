# list IPs
az vm list `
    --resource-group $resourceGroup `
    --query "[*].{Name:name, PrivateIP:privateIps, PublicIP:publicIps}" `
    --show-details `
    --output table