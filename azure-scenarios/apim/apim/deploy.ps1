$rg = 'apim'

New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $PSScriptRoot\apim-deploy.json -AsJob