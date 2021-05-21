# filter resource groups by name
$name = ''
az group list -o json --query "[?contains(name, '$name')]"