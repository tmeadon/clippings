function getCpu([datetime]$start, [datetime]$end, [string]$interval, [string]$vmId) {
    az monitor metrics list --resource $vmId --metric 'Percentage CPU' --start-time $start.ToString('s') --end-time $end.ToString('s') `
        --interval $interval --aggregation 'average' 'minimum' 'maximum' | ConvertFrom-Json
}

function getMemory([datetime]$start, [datetime]$end, [string]$interval, [string]$vmId) {
    az monitor metrics list --resource $vmId --metric 'Available Memory Bytes' --start-time $start.ToString('s') --end-time $end.ToString('s') `
        --interval $interval --aggregation 'average' 'minimum' 'maximum' | ConvertFrom-Json
}

function getCpuCreditsRemaining([datetime]$start, [datetime]$end, [string]$interval, [string]$vmId) {
    az monitor metrics list --resource $vmId --metric 'CPU Credits Remaining' --start-time $start.ToString('s') --end-time $end.ToString('s') `
        --interval $interval --aggregation 'average' 'minimum' 'maximum' | ConvertFrom-Json
}

function getAverage($metrics) {
    [math]::round(($metrics.value.timeseries.data | measure-object -Property average -Average).Average, 2)
}

function getMinimum($metrics) {
    [math]::round(($metrics.value.timeseries.data | measure-object -Property minimum -Minimum).Minimum, 2)
}

function getMaximum($metrics) {
    [math]::round(($metrics.value.timeseries.data | measure-object -Property maximum -Maximum).Maximum, 2)
}