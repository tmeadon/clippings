[CmdletBinding()]
Param
(
    # List of file extensions to filter search results by (must be in the format ".<ext>", e.g. ".jpg", ".txt")
    [Parameter()]
    [string[]]
    $FILE_EXTENSIONS,

    # Path to search below
    [Parameter(Mandatory)]
    [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
    [string]
    $SEARCH_LOCATION,

    # Directory depth to recurse through
    [Parameter()]
    [uint32]
    $SEARCH_DEPTH = 999999999,

    # Path to log file for locator
    [Parameter(Mandatory)]
    [string]
    $LOG_LOCATION,

    # Number of seconds between monitoring reports
    [Parameter()]
    [int]
    $MONITORING_FREQUENCY = 10
)

# temporarily change location to the directory holding the script
Push-Location -Path $PSScriptRoot

# store path to the file containing functions
$pathToFunctionsFile = ".\functions.ps1"

# load functions into current session
. $pathToFunctionsFile

# start a background job to run the actual search
$job = Start-Job -ScriptBlock {

    # move to the location of the script and load functions
    Set-Location -Path $using:PSScriptRoot

    . $using:pathToFunctionsFile

    # define the filter script to be used when searching for files depending upon value supplied for FILE_EXTENSIONS
    if ($using:FILE_EXTENSIONS)
    {
        $fileFilterScript = {$_.extension -in $using:FILE_EXTENSIONS}
    }
    else
    {
        $fileFilterScript = {$_.extension -like "*"}
    }

    # create a counter and an array to store duplicate files
    $processedFileCount = 0
    $duplicateFiles = @()

    Logger -LogMessage "Starting search" -LogFilePath $using:LOG_LOCATION

    # iterate through each file found that matches the filter in the supplied location and at the supplied depth
    Get-ChildItem -Path $using:SEARCH_LOCATION -File -Depth $using:SEARCH_DEPTH -Recurse | Where-Object -FilterScript $fileFilterScript | ForEach-Object -Process {

        # notch up the counter and create a temporary variable to store this file's results
        $processedFileCount++
        $results = @()

        Logger -LogMessage "Processing file $processedFileCount - $( $_.FullName )" -LogFilePath $using:LOG_LOCATION

        # call the DuplicateFileLocator function for this file
        $results += DuplicateFileLocator -FilePath $_.FullName -SearchPath $using:SEARCH_LOCATION -SearchDepth $using:SEARCH_DEPTH

        Logger -LogMessage "Search complete, found $( $results.Length ) results" -LogFilePath $using:LOG_LOCATION

        # add the returned duplicate files to the array
        $duplicateFiles += $results
    }

    return $duplicateFiles
}

# record the start time of the scan
$startDateTime = Get-Date

# whilst the background job is still running call the GetMetrics function every time interval defined by $MONITORING_FREQUENCY
do
{
    $nowDateTime = Get-Date
    $elapsedTime = $nowDateTime - $startDateTime

    if ([int]($elapsedTime.TotalSeconds % $MONITORING_FREQUENCY) -eq 0)
    {
        GetMetrics -FileLocatorLogPath $LOG_LOCATION | Format-Table
        Start-Sleep -Seconds 1
    }

    $jobState = Get-Job -Id $job.Id | Select-Object -ExpandProperty State

} while ($jobState -eq 'Running')

# collect the list of duplicate files from the background job
$duplicateFiles = Receive-Job -Id $job.Id

if ($duplicateFiles)
{
    # create the text report using the list of duplicate files
    CreateTextReport -FileList $duplicateFiles -TextReportPath .\TextReport.txt

    # notify the user that the search is complete
    Write-Output "Search complete, text report can be found at $( (Get-Location).Path )\TextReport.txt"
}
else
{
    Write-Output "Search complete, no duplicate files found"
}

# return the host to wherever it was before the script started
Pop-Location
