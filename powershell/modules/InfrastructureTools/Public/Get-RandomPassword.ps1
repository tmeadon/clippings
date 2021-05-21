Function Get-RandomPassword {
    <#
    .SYNOPSIS
    Generates a random password

    .DESCRIPTION
    Generates a random password consisting of at least: one number, one lower case character,
    one upper case character, no zero, no upper case o, no lower case l and no upper case i.

    The length of the password can be specified but defaults to 16 characters.

    .PARAMETER PasswordLength
    Length of the password to generate

    .EXAMPLE
    New-RandomPassword -PasswordLength 16
    #>

    [CmdletBinding()]
    Param (

        # Password length
        [Parameter()]
        [int]
        $PasswordLength = 16

    )

    while (($password.Length -lt $PasswordLength) -and ($password -notmatch "[0-9]") -and ($password -notmatch "^[0-9]+$") -and ($password -cnotmatch "[A-Z]") -and ($password -cnotmatch "[a-z]") -and ($password -notmatch "^[a-z0-9]+$")) {

        ### Generate Password ###

        $passwordPool = @()
        For ($a=49; $a -le 122; $a++) { # Start on "1" to skip "0"
            if($a -eq 58){ # skip from end of numbers to start of upper case letters
                $a = 65
            }
            if($a -eq 73){ # skip "I"
                $a = 74
            }
            if($a -eq 79){ # skip "O"
                $a = 80
            }
            if ($a -eq 91){ # skip from end of upper case letters to start of lower case letters
                $a = 97
            }
            if($a -eq 108){ # skip "l"
                $a = 109
            }
            $passwordPool+=[char][byte]$a
        }

        $password = Get-Random -Count $PasswordLength -InputObject $passwordPool
        $password = "$password" -replace '\s',''

    }

    $password

}
