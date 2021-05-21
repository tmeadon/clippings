$location = 'uksouth'

az group create --name "tf-management" --location $location
az storage account create --name "tfmanagement" --resource-group "tf-management" --location $location --sku "Standard_LRS"
az storage container create --name "tfstate" --account-name "tfmanagement"