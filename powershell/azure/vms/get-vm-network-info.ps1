# get all vms and their private IPs

Get-AzNetworkInterface | Select-Object ResourceGroupName, @{n='VmName';e={($_.VirtualMachine.Id | Select-String -Pattern '\/([^\/]*)$').Matches.Groups[1]}}, @{n='ip';e={$_.IpConfigurations.PrivateIpAddress}}