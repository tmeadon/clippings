using namespace System.Management.Automation

class ValidFilesGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Values = (Get-ChildItem -Path (Join-Path -Path $script:profileToolsDirectory -ChildPath 'AzureContexts') -File).BaseName
        return $Values
    }
}

function Switch-AzureAccount {
    [CmdletBinding()]
    param (
        # Path to the json file containing the Azure context to switch to (produced by Save-AzContext)
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet([ValidFilesGenerator])]
        [string]
        $AccountName
    )

    begin {}

    process {
        $contextFilePath = Join-Path -Path $script:profileToolsDirectory -ChildPath "AzureContexts\$AccountName.json"
        (Test-Path -Path $contextFilePath) ? $null : (throw ("File {0} does not exist" -f $contextFilePath))
        Import-AzContext -Path $contextFilePath
        Register-AzureSubCompleter
    }

    end {}
}
