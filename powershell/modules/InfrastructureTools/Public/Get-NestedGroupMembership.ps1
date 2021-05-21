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
        [string]
        $SamAccountName

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
