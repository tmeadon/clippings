Param (

    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$StorageSyncServiceName,

    [Parameter(Mandatory=$true)]
    [string]$ServerName

)

# Import the encrypted credential for the Azure PRTG service account.  This file needs to be created by the user account that will run this script by using the 'Export-Clixml'.
$credential = Import-Clixml "<pathToCredentialFile>"

# Begin the XML output required for PRTG to ingest the results
Write-Host "<prtg>"

# Connect to the file server and run the following script
Invoke-Command -ComputerName $ServerName -ArgumentList ($credential,$SubscriptionId,$ResourceGroupName,$StorageSyncServiceName,$ServerName) -ScriptBlock {

    Param (
        [PSCredential]$credential,
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$StorageSyncServiceName,
        [string]$ServerName
    )

    # Import the Azure File Sync module
    Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.PowerShell.Cmdlets.dll" -WarningAction SilentlyContinue

    # Connect to the Azure account using the PRTG Azure service account
    Login-AzureRmStorageSync -SubscriptionID $SubscriptionId -ResourceGroupName $ResourceGroupName -Credential $credential -ErrorAction SilentlyContinue | Out-Null

    # Iterate through the sync groups in the specified Storage Sync Service
    Get-AzureRmStorageSyncGroup -SubscriptionID $SubscriptionID -ResourceGroupName $ResourceGroupName -StorageSyncServiceName $StorageSyncServiceName | ForEach-Object -Process {

        # Retrieve all the server endpoints associated with the server
        $ServerEndpoints = Get-AzureRmStorageSyncServerEndpoint -SubscriptionId $SubscriptionID -ResourceGroupName $ResourceGroupName -StorageSyncServiceName $StorageSyncServiceName -SyncGroupName $_.name | Where-Object {$_.DisplayName -like "*$ServerName*"}
        
        # Get the number of files failing to sync for each server endpoint and output in PRTG's required XML format
        ForEach ($ServerEndpoint in $ServerEndpoints) {   
            Write-Host "<result>"
            Write-Host "<channel>"$_.name"</channel>"
            Write-Host "<value>"$ServerEndpoint.SyncStatus.LastSyncUploadItemErrorCount"</value>"
            Write-Host "</result>"
        }

    }

}

# Close the PRTG XML
Write-Host "</prtg>"
