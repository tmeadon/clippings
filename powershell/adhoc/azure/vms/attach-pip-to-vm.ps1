$rgName = ""
$vnetName = ""
$subnetName = ""
$pipName = ""
$nicName = ""
$ipConfName = ""

$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName
$pip = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $rgName
$nic | Set-AzNetworkInterfaceIpConfig -Name $ipConfName -PublicIPAddress $pip -Subnet $subnet
$nic | Set-AzNetworkInterface