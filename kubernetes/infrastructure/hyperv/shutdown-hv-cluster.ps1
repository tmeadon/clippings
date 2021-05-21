#Requires -Module 'Hyper-V'

[CmdletBinding()]
param
(
    # Name of the cluster to shut down
    [Parameter(Mandatory)]
    [string]
    $clusterName
)

Get-VM -Name "$clusterName-worker*" | Stop-VM
Get-VM -Name "$clusterName-master" | Stop-VM
Get-VM -Name "$clusterName-nfs*" | Stop-VM