class ResourceNameChecker 
{
    hidden [string[]] $Environments = @(
        'dev'
        'tst'
        'stg'
        'prd'
    )

    hidden [hashtable] $LocationAbbreviations = @{
        'East US' = 'eus1'
        'East US 2' = 'eus2'
        'Central US' = 'cus1'
        'West US' = 'wus1'
        'West US 2' = 'wus2'
        'Canada Central' = 'canc1'
        'UK South' = 'uks'
    }

    hidden [hashtable] $ResourceAbbreviations = @{
        'App Service Environment' = 'ase'
        'App Service Plan' = 'appsp'
        'App Service' = 'as'
        'Application Insights' = 'appins'
        'Automation Account' = 'aa'
        'Availability Set' = 'avs'
        'Azure Container Registry' = 'acr'
        'Azure Cosmos DB' = 'cdb'
        'Azure Data Factory' = 'df'
        'Azure Data Lake Analytics' = 'adla'
        'Azure Data Lake Store' = 'adls'
        'Azure SQL Data Warehouse PaaS' = 'sqldw'
        'Azure SQL DB PaaS' = 'sqldb'
        'Azure SQL Server PaaS' = 'sqlsrv'
        'Cloud Service' = 'csa'
        'Function App' = 'fa'
        'Internal Load Balancer' = 'ilb'
        'Local Network Gateway' = 'lng'
        'Log Analytics_' = 'dev'
        'Logic Apps' = 'la'
        'Network Interface Card' = 'nic'
        'Network Security Group' = 'nsg'
        'Public IP' = 'pip'
        'Public Load Balancer' = 'pl'
        'Recovery Services Vault_' = 'dev'
        'Resource Group' = 'rg'
        'Routing Table' = 'routetable'
        'Service Principal Name' = 'spn'
        'Storage Account' = 'sa'
        'Subnet_' = 'subnet'
        'Virtual Machine Disk Managed_' = 'nothing'
        'Virtual Machine Linux_' = 'nothing'
        'Virtual Machine Windows_' = 'nothing'
        'Virtual Network Gateway' = 'vpngw'
        'Virtual Network' = 'vnet'
        'VPN Connection' = 'vpnconn'
    }

    [string[]] ListValidLocations() 
    {
        return $this.LocationAbbreviations.Keys
    }

    [bool] IsValidName([string]$NameToTest, [string]$Location, [string]$ResourceType)
    {
        if ($Location -notin $this.LocationAbbreviations.Keys)
        {
            throw "Invalid location supplied.  Location must be one of the values: $( $this.LocationAbbreviations.Keys )"
        }

        if ($ResourceType -notin $this.ResourceAbbreviations.Keys)
        {
            throw "Invalid resource type supplied.  Resource type must be one of the values: $( $this.ResourceAbbreviations )"
        }

        $NameToTestArr = $NameToTest.Split('-')

        if (($NameToTestArr[0] -eq 'azu') -and ($NameToTestArr[1] -eq $this.LocationAbbreviations[$Location]) -and ($NameToTestArr[2] -in $this.Environments) -and ($NameToTestArr[3] -eq $this.ResourceAbbreviations[$ResourceType]))
        {
            return $true
        }
        else 
        {
            return $false
        }
    }
}