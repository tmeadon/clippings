function Save-AzureAccount {
    [CmdletBinding()]
    param (
        # Name to save the account under
        [Parameter(Mandatory)]
        [string]
        $AccountName,

        # Supply this to overwrite existing profiles with the same name
        [Parameter()]
        [switch]
        $Force
    )

    begin {}

    process {
        # check the profile tools azure contexts directory exists in the user profile and create if not
        $accountsPath = Join-Path -Path $script:profileToolsDirectory -ChildPath 'AzureContexts'
        (Test-Path -Path $accountsPath) ? $null : (New-Item -Path $accountsPath -ItemType Directory | Out-Null)

        # check if a profile already exists with that and process accordingly
        $accountFilePath = Join-Path -Path $accountsPath -ChildPath ($AccountName + ".json")
        $accountFileExists = Test-Path -Path $accountFilePath

        if (($accountFileExists -and $PSBoundParameters.ContainsKey('Force')) -or (-not $accountFileExists)) {
            Save-AzContext -Path $accountFilePath -Force
        }
        else {
            Write-Warning -Message ("Account already exists with account name {0}. Use -Force to overwrite it." -f $AccountName)
        }
    }

    end {}
}
