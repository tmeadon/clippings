$vms = az vm list --query '[].id' -o tsv

$memSizes = @{}
az vm list-sizes -l uksouth --query '[].{name:name, memoryInMb:memoryInMb}' | ConvertFrom-Json | ForEach-Object { $memSizes[$_.name] = $_.memoryInMb }

$stats = $vms | ForEach-Object -Parallel {
    . "./metrics.functions.ps1"
    $vm = $_
    $vmName = $vm.split('/')[-1]
    $now = [datetime]::now
    $memSizes = $using:memSizes

    $cpu1d = getCpu $now.AddDays(-1) $now "PT1H" $vm
    $cpu7d = getCpu $now.AddDays(-7) $now "PT1H" $vm
    $cpu30d = getCpu $now.AddDays(-30) $now "PT1H" $vm
    $cpuCredsRemaining1d = getCpuCreditsRemaining $now.AddDays(-1) $now "PT1H" $vm
    $cpuCredsRemaining7d = getCpuCreditsRemaining $now.AddDays(-7) $now "PT1H" $vm
    $cpuCredsRemaining30d = getCpuCreditsRemaining $now.AddDays(-30) $now "PT1H" $vm
    $mem1d = getMemory $now.AddDays(-1) $now "PT1H" $vm
    $mem7d = getMemory $now.AddDays(-7) $now "PT1H" $vm
    $mem30d = getMemory $now.AddDays(-30) $now "PT1H" $vm
    
    $vmSize = az vm show --id $vm --query 'hardwareProfile.vmSize' -o tsv
    $availableMemoryGB = $memSizes[$vmSize] / 1024

    [pscustomobject]@{
        'vm'                    = $vmName
        'cpu1dAverage'          = getAverage($cpu1d)
        'cpu7dAverage'          = getAverage($cpu7d)
        'cpu30dAverage'         = getAverage($cpu30d)
        'cpu1dMin'              = getMinimum($cpu1d)
        'cpu7dMin'              = getMinimum($cpu7d)
        'cpu30dMin'             = getMinimum($cpu30d)
        'cpu1dMax'              = getMaximum($cpu1d)
        'cpu7dMax'              = getMaximum($cpu7d)
        'cpu30dMax'             = getMaximum($cpu30d)
        'mem1dAverage'          = [math]::Round((((getAverage($mem1d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem7dAverage'          = [math]::Round((((getAverage($mem7d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem30dAverage'         = [math]::Round((((getAverage($mem30d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem1dMin'              = [math]::Round((((getMinimum($mem1d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem7dMin'              = [math]::Round((((getMinimum($mem7d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem30dMin'             = [math]::Round((((getMinimum($mem30d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem1dMax'              = [math]::Round((((getMaximum($mem1d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem7dMax'              = [math]::Round((((getMaximum($mem7d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'mem30dMax'             = [math]::Round((((getMaximum($mem30d)) / 1GB) / $availableMemoryGB) * 100, 2)
        'creditsLeft1dAverage'  = getAverage($cpuCredsRemaining1d)
        'creditsLeft7dAverage'  = getAverage($cpuCredsRemaining7d)
        'creditsLeft30dAverage' = getAverage($cpuCredsRemaining30d)
        'creditsLeft1dMin'      = getMinimum($cpuCredsRemaining1d)
        'creditsLeft7dMin'      = getMinimum($cpuCredsRemaining7d)
        'creditsLeft30dMin'     = getMinimum($cpuCredsRemaining30d)
        'creditsLeft1dMax'      = getMaximum($cpuCredsRemaining1d)
        'creditsLeft7dMax'      = getMaximum($cpuCredsRemaining7d)
        'creditsLeft30dMax'     = getMaximum($cpuCredsRemaining30d)
    }
}