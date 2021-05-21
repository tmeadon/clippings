Import-Module 'Microsoft.Online.SharePoint.PowerShell'

# Save the user's UPN
$user = '<user>'

# Connect to source sharepoint online service
Connect-SPOService -Url '<spoServiceUrl>'

# Validate the move
Start-SPOUserAndContentMove -UserPrincipalName $user -DestinationDataLocation GBR -ValidationOnly

# Start the migration
Start-SPOUserAndContentMove -UserPrincipalName $user -DestinationDataLocation GBR

# Check the migration progress
Get-SPOUserAndContentMoveState -UserPrincipalName $user