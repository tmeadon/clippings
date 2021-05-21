function New-CosmosDBRESTAuthToken {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]$Verb,
        [Parameter()]
        [String]$ResourceType,
        [Parameter()]
        [String]$ResourceId,
        [Parameter()]
        [String]$Date = [System.DateTime]::UtcNow.ToString("R"),
        [Parameter()]
        [String]$Key,
        [Parameter()]
        [String]$KeyType,
        [Parameter()]
        [String]$TokenVersion
    )

    $HMACSHA = [System.Security.Cryptography.HMACSHA256]::new()
    $HMACSHA.Key = [Convert]::FromBase64String($Key)  #[Text.Encoding]::ASCII.GetBytes($secret)

    $Payload = [String]::Format([System.Globalization.CultureInfo]::InstalledUICulture, "{0}\n{1}\n{2}\n{3}\n{4}\n",
        ` $verb.ToLowerInvariant(), 
        ` $resourceType.ToLowerInvariant(),  
        ` $resourceId,  
        ` $date.ToLowerInvariant(),"" 
    )
    write-host $Date
    [Byte[]]$HashPayLoad = $HMACSHA.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Payload))
    $Signature = [Convert]::ToBase64String($hashPayLoad)

    [System.Web.HttpUtility]::UrlEncode([String]::Format([System.Globalization.CultureInfo]::InstalledUICulture,"type={0}&ver={1}&sig={2}",  
        ` $KeyType,  
        ` $TokenVersion,  
        ` $Signature
    ))
}

$key = "xxx"
New-CosmosDBRESTAuthToken -Verb GET -ResourceType 'dbs' -ResourceId "<collResourceId>" -KeyType "master" -TokenVersion "2.0" -Key $key