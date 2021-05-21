function ReadAllCosmosDocs ([CosmosDB.Context] $Context, [string] $CollectionId)
{
    $documentsPerRequest = 20
    $continuationToken = $null
    $documents = $null

    do {
        $responseHeader = $null
        $getCosmosDbDocumentParameters = @{
            Context = $Context
            CollectionId = $CollectionId
            MaxItemCount = $documentsPerRequest
            ResponseHeader = ([ref] $responseHeader)
        }

        if ($continuationToken) {
            $getCosmosDbDocumentParameters.ContinuationToken = $continuationToken
        }

        $documents += Get-CosmosDbDocument @getCosmosDbDocumentParameters
        $continuationToken = Get-CosmosDbContinuationToken -ResponseHeader $responseHeader
    } while (-not [System.String]::IsNullOrEmpty($continuationToken))

    $documents
}