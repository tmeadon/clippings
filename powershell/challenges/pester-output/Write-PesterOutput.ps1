[CmdletBinding()]
Param (
    # Path to XML files
    [Parameter(Mandatory)]
    [string]
    $PathToXmlFile
)

# Load helpers

Get-ChildItem -Path "$PSScriptRoot\helpers" | ForEach-Object {
    . $_.FullName
}

# Validate input file

if (-not (Test-Path -Path $PathToXmlFile)) {
    throw "Can't find file $PathToXmlFile"
}

try {
    $xml = [xml] (Get-Content -Path $PathToXmlFile)
}
catch {
    throw "File $PathToXmlFile does not contain valid XML"
}

if (-not (Test-SupportedOutputFormat -XmlDocument $xml)) {
    throw "File $PathToXmlFile does not contain the correct test output format.  Supported formats are: NUnit"
}

Write-PesterOutput -XmlDocument $xml