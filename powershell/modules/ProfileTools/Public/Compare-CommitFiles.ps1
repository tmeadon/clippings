function Compare-CommitFiles
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $ReferenceCommitId,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $DifferenceCommitId
    )
    
    process
    {
        $output = Invoke-Expression -Command "git diff --name-only $refCommit $diffCommit 2>&1"

        if ($output -match "error: could not access")
        {
            throw "Could not find commits.  Ensure you have changed into the directory containing the git repo the commits belong to."
        }
        
        $output
    }
}