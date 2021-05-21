$rg = "<rgName>"

$functionAppNames = (Get-ChildItem -Path $PSScriptRoot -Directory).Name

New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $PSScriptRoot\fa-deploy.json -functionAppNames $functionAppNames -Verbose

$functionAppNames | ForEach-Object -Parallel {
    $zipPath = "$using:PSScriptRoot\$_.zip"
    Compress-Archive -Path "$using:PSScriptRoot\$_\*" -DestinationPath $zipPath
    Publish-AzWebApp -ResourceGroupName $using:rg -Name $_ -ArchivePath $zipPath -Force | Select Name, State
    Remove-Item $zipPath -Force
}
