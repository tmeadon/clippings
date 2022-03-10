$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName 'update-mgmt'

$query = @"
Update
| where TimeGenerated > ago(14h) and (Optional==false or Classification has "Critical" or Classification has "Security") and UpdateState =~ "Needed"
| project KBID, Title, PublishedDate
"@

$results = Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $query