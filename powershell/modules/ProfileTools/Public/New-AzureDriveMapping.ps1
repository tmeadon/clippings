function New-AzureDriveMapping
{
    [CmdletBinding()]
    param ()
    
    process
    {
        Import-Module -Name 'AzurePSDrive' -ErrorAction Stop

        $drive = Get-PSDrive -Name 'azure' -ErrorAction SilentlyContinue
        if ($drive) { Remove-PSDrive -Name $drive.Name }
        New-PSDrive -name azure -PSProvider SHiPS -Root 'AzurePSDrive#Azure' -Scope 'Global'
    }
}