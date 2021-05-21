$rg = '<rgname>'

New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $PSScriptRoot\deploy.json