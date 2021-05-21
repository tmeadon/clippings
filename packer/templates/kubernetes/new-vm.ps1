[CmdletBinding()]
param
(
    [string] $name
)

# check for existing VMs with the same name
if (Get-VM -Name $name -ErrorAction SilentlyContinue) { throw "VM $name already exists" }

# store source and destination paths
$hostHdPath = Get-VMHost | Select-Object -ExpandProperty 'VirtualHardDiskPath'
$sourceVhdx = Get-Item -Path "$PSScriptRoot\output-hyperv-iso\Virtual Hard Disks\packer-centos-7-x86_64-kubernetes.vhdx"
$destVhdx = "$hostHdPath\$name.vhdx"

# make a copy of the vhdx image
Copy-Item -Path $sourceVhdx -Destination $destVhdx

# create a VM
$vmParams = @{
    Name = $name
    MemoryStartupBytes = 2GB
    Generation = 1
    VHDPath = $destVhdx
    BootDevice = 'VHD'
    SwitchName = 'External'
}

New-VM @vmParams | Out-Null

Set-VM -Name $name -ProcessorCount 2

# boot the VM
Start-VM -Name $name

# wait for the VM to boot and get an IP 
$start = Get-Date
do
{
    $ipAddress = (Get-VMNetworkAdapter -VMName $name).IPAddresses.Where({ $_ -match "\." })
    Start-Sleep -Milliseconds 500
    if (((Get-Date) - $start).TotalSeconds -gt 60) { throw "Timed out waiting for VM to boot" }
} 
while (-not $ipAddress)

$output = [PSCustomObject]@{
    Name = $name
    IPAddress = $ipAddress
}

Write-Output $output