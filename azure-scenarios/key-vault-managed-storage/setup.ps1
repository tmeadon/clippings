# create storage and key vault
$resourceGroupName = ""
$storageAccountName = ""
$keyVaultName = ""
$storage = New-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -SkuName Standard_LRS -Location 'uksouth' -Kind StorageV2 -AccessTier Cool
$storage | New-AzStorageContainer -Name 'test'
$kv = New-AzKeyVault -ResourceGroupName $resourceGroupName -Name $keyVaultName -Location "uksouth"

# give key vault access to storage
$appid = 'cfa8b339-82a2-471a-a3c9-0fc0be7a4093'
New-AzRoleAssignment -ApplicationId $appid -Scope $storage.Id -RoleDefinitionName 'Storage Account Key Operator Service Role'

# add managed storage account
Add-AzKeyVaultManagedStorageAccount -VaultName $kv.VaultName -AccountName $storage.StorageAccountName -AccountResourceId $storage.Id -ActiveKeyName 'key1' -RegenerationPeriod (New-TimeSpan -Days 1)

# create a template sas token
$sas = New-AzStorageAccountSASToken -Service 'blob','file','table','queue' -ResourceType Service,Container,Object -Permission 'racwdlup' -Protocol HttpsOnly -StartTime (get-date).AddDays(-1) -ExpiryTime (Get-Date).AddDays(100) -Context $stor.Context

# create a managed storage sas definition
$sasDefName = ""
$sasDef = Set-AzKeyVaultManagedStorageSasDefinition -AccountName $stor.StorageAccountName -VaultName $kv.VaultName -Name $sasDefName -TemplateUri $sas -SasType 'account' -ValidityPeriod (New-TimeSpan -Days 30)

# get a sas key and test
$sasToken = Get-AzKeyVaultSecret -VaultName $kv.VaultName -AsPlainText -Name "$($sasDef.Sid.Split("/")[-1])"
$ctx = New-AzStorageContext -StorageAccountName $stor.StorageAccountName -SasToken $sasToken
Get-AzStorageBlob -Container 'test' -Context $ctx

# update key 1 and set as active
Update-AzKeyVaultManagedStorageAccountKey -VaultName $kv.VaultName -AccountName $stor.StorageAccountName -KeyName key1

# update key 2 and set as active
Update-AzKeyVaultManagedStorageAccountKey -VaultName $kv.VaultName -AccountName $stor.StorageAccountName -KeyName key2
