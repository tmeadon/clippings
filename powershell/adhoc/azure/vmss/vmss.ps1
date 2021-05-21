# create resource group
$resourceGroup = New-AzResourceGroup -Name 'vmss1' -Location 'uksouth'

# create vmss
$vmPassword = ConvertTo-SecureString -String '<password>' -AsPlainText -Force
$vmCredential = New-Object -TypeName System.Management.Automation.PSCredential('tom', $vmPassword)

$vmssParams = @{
    ResourceGroupName = $resourceGroup.ResourceGroupName
    Location = $resourceGroup.Location
    VmScaleSetName = 'vmss'
    SubnetName = 'vmssSubnet'
    PublicIpAddressName = 'vmssPIP'
    LoadBalancerName = 'vmssLoadBalancer'
    UpgradePolicyMode = 'Automatic'
    Credential = $vmCredential
}

$vmss = New-AzVmss @vmssParams

$vmss = Get-AzVmss -ResourceGroupName $resourceGroup.ResourceGroupName -VMScaleSetName 'vmss'

# create nsg
$nsgRuleParams = @{
    Name = 'allowHTTP'
    Protocol = 'Tcp'
    Direction = 'Inbound'
    Priority = 200
    SourceAddressPrefix = '*'
    SourcePortRange = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange = 80
    Access = 'Allow'
}

$nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleParams

$nsgParams = @{
    ResourceGroupName = $resourceGroup.ResourceGroupName
    Location = $resourceGroup.Location
    Name = 'vmssnsg'
    SecurityRules = $nsgRule
}

$nsg = New-AzNetworkSecurityGroup @nsgParams

# assign nsg and update vnet and vmss
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -Name 'vmss'

$subnet = $vnet.Subnets[0]

$subnetConfigParams = @{
    VirtualNetwork = $vnet
    Name = 'vmssSubnet'
    AddressPrefix = $subnet.AddressPrefix
    NetworkSecurityGroup = $nsg
}

$subnetConfig = Set-AzVirtualNetworkSubnetConfig @subnetConfigParams

Set-AzVirtualNetwork -VirtualNetwork $vnet

Update-AzVmss -ResourceGroupName $resourceGroup.ResourceGroupName -Name $vmss.Name -VirtualMachineScaleSet $vmss

# add script to configure servers
$publicSettings = @{
    "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}


$extParams = @{
    VirtualMachineScaleSet = $vmss
    Name = 'CustomScript'
    Publisher = 'Microsoft.Compute'
    Type = 'CustomScriptExtension'
    TypeHandlerVersion = 1.9
    Setting = $publicSettings
}

Add-AzVmssExtension @extParams

Update-AzVmss -ResourceGroupName $resourceGroup.ResourceGroupName -Name $vmss.Name -VirtualMachineScaleSet $vmss

# verify
$fqdn = (Get-AzPublicIpAddress -Name 'vmssPIP').DnsSettings.Fqdn

Invoke-WebRequest -UseBasicParsing -Uri $fqdn