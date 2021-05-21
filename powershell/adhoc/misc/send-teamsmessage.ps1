function Send-TeamsMessage {
    <#
    .SYNOPSIS
    This function sends a Teams message to a channel which can contain multiple sections.

    .DESCRIPTION
    This sends a message to a Teams channel.  Before this can be run an incoming webhook connector needs to be created for the channel, as described here:
    https://github.com/sjkp/Microsoft-teams-docs/blob/master/teams/connectors.md.

    The message body can be formatted either using HTML or markdown as described here:
    https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/cards/cards-format#html-formatting-for-simple-cards.

    Multiple comma separated strings can be supplied for the message body and each string will appear in a separate section in the Teams message.

    .PARAMETER WebhookUrl
    Teams channel webhook connector URL

    .PARAMETER MessageTitle
    Teams message title

    .PARAMETER MessageBody
    Message body to send to the Teams channel, each collection member is a separate section in the message.  Can be formatted as markdown or HTML.

    .EXAMPLE
    Send-TeamsMessage -WebhookUrl "https://outlook.office.com/webhook/XXX" -MessageTitle "Example Message" -MessageBody "<h1>This is an example</h1><p>hello!</p>"
    #>

    [CmdletBinding()]
    Param (

        # Teams channel webhook connector URL
        [Parameter(Mandatory)]
        [ValidateScript({$_ -like "https://outlook.office.com/webhook/*"})]
        [string]
        $WebhookUrl,

        # Teams message title
        [Parameter()]
        [string]
        $MessageTitle,

        # Message body to send to the Teams channel, each collection member is a separate section in the message.
        # Can be formatted as markdown or HTML.
        [Parameter()]
        [string[]]
        $MessageBody

    )

    Process {

        # First create the basis of the REST call then add an item to the section collection for each message body string supplied.
        # Then invoke the REST method in a try/catch block to report useful error details back to the user if the REST method fails.

        $Hash = @{
            '@Type' = "MessageCard"
            '@Context' = "http://schema.org/extensions"
            'Summary' = "Summary"
            'Title' = $MessageTitle
            'Sections' = @()
        }

        foreach ($Section in $MessageBody) {

            $Hash.Sections += @{ 'text' = $Section }

        }

        $Json = ConvertTo-Json -InputObject $Hash

        try {

            # The value for the -ContentType parameter was taken from here:
            # https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/cards/cards-format#formatting-sample-for-html-connector-cards

            $Result = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $Json -ContentType "application/vnd.microsoft.teams.card.o365connector" -ErrorAction Stop

            if ($Result -ne 1) { throw }

        }
        catch {

            $ErrorDetails = $_.ErrorDetails

            switch -Wildcard ($_.Exception.Message) {

                "*(404) Not Found*"     {Write-Error -Message "HTTP request returned (404) Not Found.  Check the webhook URL."}
                "*(400) Bad Request*"   {Write-Error -Message "HTTP request returned (400) Bad Request.  Response message: $ErrorDetails"}
                default                 {Write-Error $_.Exception.Message}

            }
        }
    }
}
