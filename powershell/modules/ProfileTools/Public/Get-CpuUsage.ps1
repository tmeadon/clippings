function Get-CpuUsage
{
    [CmdletBinding()]
    param
    (
        # Switch to just return total CPU usage
        [Parameter(ParameterSetName = 'Total')]
        [switch]
        $Total,

        # Number of items to limit to
        [Parameter(ParameterSetName = 'List')]
        [int]
        $Top
    )
    
    begin {}
    
    process
    {
        if ($Total)
        {
            (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples
        }
        else
        {
            $numCores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
            $counters = (Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples | Sort-Object -Property CookedValue -Descending

            if ($Top) { $counters = $counters | Select-Object -First $Top }

            foreach ($counter in $counters)
            {
                [PSCustomObject]@{
                    ProcessName = $counter.InstanceName
                    PercentCPU  = [math]::Round(($counter.CookedValue / $numCores), 2)
                }
            }
        }
    }
    
    end {}
}