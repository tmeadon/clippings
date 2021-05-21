$rg = 'apim'

New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $PSScriptRoot\appgw-deploy.json -AsJob