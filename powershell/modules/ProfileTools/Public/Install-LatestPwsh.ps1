function Install-LatestPwsh {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression","")]
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'msi')]
        [switch] $msi,

        [Parameter(ParameterSetName = 'daily')]
        [switch] $daily,

        [Parameter()]
        [switch] $preview
    )

    Process {
        $exp = "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) }"

        switch ($PSCmdlet.ParameterSetName) {
            'msi' {
                $exp += " -UseMSI"
            }
            'daily' {
                $exp += " -UseMSI"
            }
        }

        if ($preview) {
            $exp += " -Preview"
        }

        Invoke-Expression -Command $exp
    }
}