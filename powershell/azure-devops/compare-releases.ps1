#Requires -Module VSTeam

function Get-ReleaseCommitIds
{
    [CmdletBinding()]
    param
    (
        # Definition ID of the release
        [Parameter(Mandatory)]
        [string]
        $ReleaseDefinitionId,

        # Optionally filter by releases that included the given stage
        [Parameter()]
        [string]
        $ReleaseStageName,

        # Name of the Azure DevOps project
        [Parameter(Mandatory)]
        [string]
        $ProjectName
    )
    
    begin {}

    process
    {
        $releases = Get-VSTeamRelease -definitionId $ReleaseDefinitionId -ProjectName $ProjectName

        $result = $releases | ForEach-Object -Parallel {
            $thisRelease = Get-VSTeamRelease -id $_.Id -ProjectName $_.Project
            Write-Verbose $thisRelease.Name

            if ($using:ReleaseStageName)
            {
                if ($thisRelease.Environments.Where({$_.Name -eq $using:ReleaseStageName}).Status -eq 'notStarted')
                {
                    return
                }
            }
            
            [PSCustomObject]@{
                Name = $thisRelease.Name
                CreatedOn = $thisRelease.CreatedOn
                CommitId = $thisRelease.InternalObject.artifacts.definitionReference.sourceVersion.id
                Branch = $thisRelease.InternalObject.artifacts.definitionReference.branch.name
            }
        }

        $result | Sort-Object -Property CreatedOn -Descending
    }
    
    end {}
}

function Get-FilesChangedBetweenCommits ($refCommit, $diffCommit)
{
    $output = Invoke-Expression -Command "git diff --name-only $refCommit $diffCommit 2>&1"

    if ($output -match "error: could not access")
    {
        throw "Could not find commits.  Ensure you have changed into the directory containing the git repo the commits belong to."
    }
    
    $output
}