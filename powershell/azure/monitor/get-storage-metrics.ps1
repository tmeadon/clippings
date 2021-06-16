function Get-StorageAccountTransactionMetrics
{
    [CmdletBinding()]
    param
    (
        # Resource ID of the storage account
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]
        $StorageAccountId
    )

    begin {}

    process
    {
        $transactionMetricParams = @{
            ResourceId      = "$StorageAccountId/fileServices/default"
            MetricName      = 'Transactions'
            StartTime       = (Get-Date).AddMinutes(-5)
            AggregationType = 'Count'
            WarningAction   = 'SilentlyContinue'
            ErrorAction     = 'Stop'
        }
        $transactionMetrics = Get-AzMetric @transactionMetricParams
    
        $dataMetricParams = @{
            ResourceId      = "$StorageAccountId/fileServices/default"
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
            StorageAccount = $StorageAccountId.Split('/')[-1]
            TotalTransactions = $totalTransactions.Sum
            IngressMB = '{0:n2}' -f ($ingress.Sum / 1MB)
            EgressMB = '{0:n2}' -f ($egress.Sum / 1MB)
        }
    }

    end {}
}

function Get-StorageAccountShareConnections
{
    [CmdletBinding()]
    param
    (
        # Resource ID of the storage account
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]
        $StorageAccountId
    )
    
    begin {}
    
    process
    {
        $sa = Get-AzResource -Id $StorageAccountId | Get-AzStorageAccount
        $shares = $sa | Get-AzStorageShare -ea SilentlyContinue | Select-Object @{n='StorageAcc';e={$sa.StorageAccountName}}, @{n='ShareName';e={$_.Name}}, @{n='NumHandles';e={($_ | Get-AzStorageFileHandle -Recursive | Measure-Object).Count}}, @{n='AccessTier';e={$sa | Get-AzRmStorageShare -ShareName $_.Name | Select-Object -expand accesstier}}
        $shares
    }
    
    end {
        
    }
}