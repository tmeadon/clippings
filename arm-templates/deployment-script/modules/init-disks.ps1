param([string] $ResourceGroupName)

# write the disk initialisation script out to disk
$script = @"
`$rawDisks = Get-Disk | Where {`$_.PartitionStyle -eq 'RAW'}

`$rawDisks | ForEach-Object {
    `$_ | Initialize-Disk -PartitionStyle GPT | New-Partition -UseMaximumSize 
    New-Volume -Disk `$_ -FriendlyName 'data' -FileSystem NTFS
}
"@

Set-Content -Path .\script.ps1 -Value $script

# connect to azure using the attached MSI
Connect-AzAccount -Identity

# list the VMs and run the disk initialisation script against each one in parallel
$vms = Get-AzVM -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'Windows'}

$vms | ForEach-Object -Parallel {

    $cmd = Invoke-AzVMRunCommand -VMName $_.Name -ResourceGroupName $_.ResourceGroupName -CommandId 'RunPowerShellScript' -ScriptPath .\script.ps1

    [PSCustomObject]@{
        VMName = $_.Name
        Result = $cmd.Status
    }

}
