
# load the classes in a specific order 
. "$PSScriptRoot\Classes\NasuniFiler.ps1"
. "$PSScriptRoot\Classes\NasuniVolumeFilerConnection.ps1"
. "$PSScriptRoot\Classes\NasuniVolume.ps1"

# dot source all public and private funtions
foreach ($item in (Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -Recurse))
{
    . $item.FullName
}

# export only public functions
foreach ($item in (Get-ChildItem -Path $PSScriptRoot\Public -Filter "*.ps1" -Recurse))
{
    Export-ModuleMember -Function $item.BaseName
}