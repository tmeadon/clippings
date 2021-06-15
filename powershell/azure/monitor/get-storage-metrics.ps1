# get storage account file service metrics
$storageAccounts = Get-AzStorageAccount

$storageAccounts | ForEach-Object -Parallel {
    $sa = $_

    $transactionMetricParams = @{
        ResourceId      = "$($sa.Id)/fileServices/default"
        MetricName      = 'Transactions'
        StartTime       = (Get-Date).AddMinutes(-5)
        AggregationType = 'Count'
        WarningAction   = 'SilentlyContinue'
        ErrorAction     = 'Stop'
    }
    $transactionMetrics = Get-AzMetric @transactionMetricParams

    $dataMetricParams = @{
        ResourceId      = "$($sa.Id)/fileServices/default"
        MetricName      = 'Ingress', 'Egress'
        StartTime       = (Get-Date).AddMinutes(-5)
        AggregationType = 'Total'
        WarningAction   = 'SilentlyContinue'
        ErrorAction     = 'Stop'
    }
    $dataMetrics = Get-AzMetric @dataMetricParams
    
    $totalTransactions = $transactionMetrics.where({$_.Name.Value -eq 'Transactions'}).Data | Measure-Object -Property 'Count' -Sum
    $ingress = $dataMetrics.where({$_.Name.Value -eq 'Ingress'}).Data | Measure-Object -Property Total -Sum -Average
    $egress = $dataMetrics.where({$_.Name.Value -eq 'Egress'}).Data | Measure-Object -Property Total -Sum -Average

    [PSCustomObject]@{
        StorageAccount = $sa.StorageAccountName
        TotalTransactions = $totalTransactions.Sum
        IngressMB = '{0:n2}' -f ($ingress.Sum / 1MB)
        EgressMB = '{0:n2}' -f ($egress.Sum / 1MB)
    }
}