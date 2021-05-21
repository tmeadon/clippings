function Get-NestedGroupMembership {
    <#
    .SYNOPSIS
    Gets a user's or group's direct and indirect (by group nesting) group membership recursively.

    .PARAMETER SamAccountName
    # SamAccountName of user or group to retrieve nested group memberships for.

    .EXAMPLE
    Get-NestedGroupMembership -SamAccountName example.user

    .EXAMPLE
    Get-ADUser -Identity example.user | Get-NestedGroupMembership
    #>

    #Requires -Modules @{ ModuleName = 'ActiveDirectory'; ModuleVersion = '1.0.0.0' }

    [CmdletBinding()]
    Param(

        # SamAccountName of user or group to retrieve nested group memberships for.  Accepts single values only.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SamAccountName

    )

    Begin {

        # Import the ActiveDirectory module and set the $Depth variable to track recursion depth

        Import-Module 'ActiveDirectory' -Verbose:$false

        if ($Depth -ge 1) {
            $Depth ++
        } else {
            $Depth = 1
        }

    }
    Process {

        # Store the username of the original user whose nested group membership was requested then
        # output the group memberships at the current recursion depth before calling this function again
        # to increase the recursion depth

        if ($Depth -le 1) {
            $OriginalPrincipalName = $SamAccountName
        }

        $Groups = Get-ADPrincipalGroupMembership -Identity $SamAccountName

        foreach ($Group in $Groups) {

            [PSCustomObject]@{
                Principal = $OriginalPrincipalName
                GroupName = $Group.Name
                Parent = $SamAccountName
            }

            Get-NestedGroupMembership -SamAccountName $Group.SamAccountName

        }
    }
    End {

        # Decrease the recursion depth before finishing

        if ($Depth -eq 1) {
            $Depth = 0
        } else {
            $Depth--
        }
    }
}



# SIG # Begin signature block
# MIIIowYJKoZIhvcNAQcCoIIIlDCCCJACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/kjyvId0nmc2On+/ourwNbun
# WcOgggYGMIIGAjCCBOqgAwIBAgIKPRL+mwAAAAFDKjANBgkqhkiG9w0BAQUFADBY
# MRIwEAYKCZImiZPyLGQBGRYCdWsxEjAQBgoJkiaJk/IsZAEZFgJjbzEYMBYGCgmS
# JomT8ixkARkWCGR2Y3NhbGVzMRQwEgYDVQQDEwtTS1lDQTAwMS1DQTAeFw0xOTAz
# MjUxNTQwMDVaFw0yMDAzMjQxNTQwMDVaMIGSMRIwEAYKCZImiZPyLGQBGRYCdWsx
# EjAQBgoJkiaJk/IsZAEZFgJjbzEYMBYGCgmSJomT8ixkARkWCGR2Y3NhbGVzMQww
# CgYDVQQLEwNNSVMxEjAQBgNVBAsTCU1JUyBVc2VyczEVMBMGA1UECxMMVXNlciBT
# dXBwb3J0MRUwEwYDVQQDEwxBZG1pbiBTdGVlbGUwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDQ+7ixF4qXVOyMntKfhE1UWzAkDXERYYQy+qMsdH8ZQOn8
# 29i3545wYgbai4Yuo2LEJCR9jWkdIXMOWtma9ZJVtgzhAlyd2KW+mwkQN0fZbUC7
# vDQT68aLNKmt0KqKxNxY2ZcwtJxceY5U6gvS8cucrxmnvH0cWpd/oQdJIJVpIFLZ
# +OwbG2Al4iynKobeRGwKBjKpvOk8/GvcTxSkKsqgQcOSbZqm4Eq7YzsCsuOsl/TR
# A5CctM8NaFcVMnnKLDO5K26lKW/RUYwGYYi5s9JV0tbcHAahYft0sh/k6vQi4n4R
# wmY/fqMa/gzQTVcjl4of32f27qkwduJauPVKIU3dAgMBAAGjggKRMIICjTA7Bgkr
# BgEEAYI3FQcELjAsBiQrBgEEAYI3FQiE+maokCKF6ZEEgvSTc4e/v3hkg5biN4XL
# 2lwCAWQCAQQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwCwYDVR0PBAQDAgeAMBsGCSsG
# AQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFCiyZdX90A8RfmN1/pzJ
# PC/DzXgIMB8GA1UdIwQYMBaAFPCWS827SFPyDsaJ/4AMIPRBA6w8MIHQBgNVHR8E
# gcgwgcUwgcKggb+ggbyGgblsZGFwOi8vL0NOPVNLWUNBMDAxLUNBLENOPXNreWNh
# MDAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNl
# cyxDTj1Db25maWd1cmF0aW9uLERDPWR2Y3NhbGVzLERDPWNvLERDPXVrP2NlcnRp
# ZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmli
# dXRpb25Qb2ludDCBwwYIKwYBBQUHAQEEgbYwgbMwgbAGCCsGAQUFBzAChoGjbGRh
# cDovLy9DTj1TS1lDQTAwMS1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2Vy
# dmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1kdmNzYWxlcyxE
# Qz1jbyxEQz11az9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlm
# aWNhdGlvbkF1dGhvcml0eTA2BgNVHREELzAtoCsGCisGAQQBgjcUAgOgHQwbQWRt
# aW4uU3RlZWxlQGR2Y3NhbGVzLmNvLnVrMA0GCSqGSIb3DQEBBQUAA4IBAQBvlz9q
# 1AU3qI02227oPg7a223nK+8zsiCQNHPUEGzePjdM2qgYbVPMfWSNyY/1YF+PPu1+
# 6NglaQlqNeCo/03RwGp0DEcPzfyn+Fg1Uy5gpg5c+gpt5kYQKB4vIBfhSngi5RWl
# Sc4thYznGyfQ01GX0K7xI4eAvyitgqqzAXHd7y7iXhQsP06az493+tERxEYVSLTu
# GfCAANPrTXtcmqZnT2eUjkkUmRoDXzIffzqG5WnABcJeshRgQwH2XRelAtx9q2tz
# Nczyv7ZLWsiG8JUQip4MxDo17N+5BEpp3lfsPUnsSlPptO7F/eNEd9tR6EEA8NCL
# 5XyGzT8hNjr31RchMYICBzCCAgMCAQEwZjBYMRIwEAYKCZImiZPyLGQBGRYCdWsx
# EjAQBgoJkiaJk/IsZAEZFgJjbzEYMBYGCgmSJomT8ixkARkWCGR2Y3NhbGVzMRQw
# EgYDVQQDEwtTS1lDQTAwMS1DQQIKPRL+mwAAAAFDKjAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# ap0IQkDWm4TlhAJ8EKxb/OXdKoIwDQYJKoZIhvcNAQEBBQAEggEAiQhzf+gLfbsT
# IYoaS5ZWrKRStNccDoW616IGE3KZ9Nd+RutUSLJNqGuqXZftNkBvG+yjWU/M+z5W
# ENXHIkGz5FMgrT3eoWkqokIHptTwkno6RSA+mztZc/9ZsP5ruuazOJjm1Y6aPAgq
# gIkPIaTLrTekShXGCzrq9ZmrQ06squKHJelkzQrVzOkTg1PNe6uGzRIECF92bhPw
# KAMXo5wwg1CXylrG7ZIswTWMkU4jUHgFyL3JxeWIsvdti3/gj66OfkDcjkkg60HQ
# MCvuP/cx3gYsNXdL6gLSowo9A3nAka2wV9k+7QK/NQYR8a7SMNRNLhm7wcmjdaUn
# ZTam/Mn9aQ==
# SIG # End signature block
