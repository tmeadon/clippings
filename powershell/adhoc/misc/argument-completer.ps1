function Select-Item
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

                Get-ChildItem | Select-Object -ExpandProperty Name
            }
        )]
        [string]
        $Item
    )

    Get-Item -Path $Item
}