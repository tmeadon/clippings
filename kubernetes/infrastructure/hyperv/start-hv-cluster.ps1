#Requires -Module 'Hyper-V'

[CmdletBinding()]
param
(
    # Name of the cluster to shut down
    [Parameter(Mandatory)]
    [string]
    $clusterName
)

# start nfs servers
Get-VM -Name "$clusterName-nfs*" | Start-VM

# start master and wait for it to boot
Get-VM -Name "$clusterName-master" | Start-VM

$start = Get-Date
do
{
    $ipAddress = (Get-VMNetworkAdapter -VMName "$clusterName-master").IPAddresses.Where({ $_ -match "\." })
    Start-Sleep -Milliseconds 500
    if (($start - (Get-Date)) -gt 60) { throw "Timed out waiting for VM to boot" }
} 
while (-not $ipAddress)

# start workers
Get-VM -Name "$clusterName-worker*" | Start-VM
