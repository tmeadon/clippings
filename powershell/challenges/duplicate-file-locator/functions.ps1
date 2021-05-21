function DuplicateFileLocator
{
    <#
    .SYNOPSIS
    This function searches a directory for duplicate files based on name, size and last write time.  It logs progress and returns a list of duplicate files.

    .PARAMETER SearchPath
    Path to the directory to search beneath

    .PARAMETER SearchDepth
    Number of subdirectories to recurse through when searching

    .PARAMETER SearchFileExtensions
    File extensions to filter by when searching (accepts multiple values)

    .PARAMETER LogFilepath
    Path to a file to log into

    .EXAMPLE
    DuplicateFileLocator -SearchPath C:\Directory -SearchDepth 3 -SearchFileExtensions *.jpg, *.docx -LogFilepath C:\Directory\log.txt
    #>

    [CmdletBinding()]
    Param
    (
        # Path to the file to search for duplicates of
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string]
        $FilePath,

        # Path to the directory to search beneath
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
        [string]
        $SearchPath,

        # Number of subdirectories to recurse through when searching
        [Parameter()]
        [uint32]
        $SearchDepth = 999999999
    )

    # store details about the reference file
    $referenceFile = Get-Item -Path $FilePath

    # create a filter script to identify duplicates - must not be the same file, must have the same name, must be the same size and must have the same last write time
    $fileFilterScript = {($_.Fullname -ne $referenceFile.FullName) -and ($_.Name -eq $referenceFile.Name) -and ($_.Length -eq $referenceFile.Length) -and ($_.LastWriteTime -eq $referenceFile.LastWriteTime)}

    # search for files that match the filter script
    $duplicateFiles = Get-ChildItem -Path $SearchPath -File -Recurse -Depth $SearchDepth | Where-Object -FilterScript $fileFilterScript | Select-Object -ExpandProperty 'FullName'

    # return the matches
    return $duplicateFiles
}

function CreateTextReport
{
    <#
    .SYNOPSIS
    This function creates a text report which lists paths to duplicate files grouped by base file name.

    .PARAMETER FileList
    Array of paths to duplicate files

    .PARAMETER TextReportPath
    Path to a file to store the text report

    .EXAMPLE
    CreateTextReport -FileList $fileList -TextReportPath C:\Directory\TextReport
    In this example $fileList contains the output of the DuplicateFileLocator function
    #>

    [CmdletBinding()]
    Param
    (
        # Array of paths to duplicate files
        [Parameter(Mandatory)]
        [string[]]
        $FileList,

        # Path to a file to store the text report
        [Parameter(Mandatory)]
        [string]
        $TextReportPath
    )

    # delete a pre-existing text report
    Remove-Item -Path $TextReportPath -Force

    # get the unique file names
    $uniqueFileNames = $FileList | Split-Path -Leaf | Sort-Object -Unique

    Add-Content -Path $TextReportPath -Value "This file contains details of the duplicate files that have been located.  The files are grouped by name."

    foreach ($fileName in $uniqueFileNames)
    {
        Add-Content -Path $TextReportPath -Value "`nPaths to files with filename: $fileName"
        Add-Content -Path $TextReportPath -Value ($FileList | Where-Object {(Split-Path -Path $_ -Leaf) -eq $fileName} | Sort-Object -Unique)
    }
}

function Logger
{
    <#
    .SYNOPSIS
    This is a helper function to ensure a consistent logging format which is prefixed with the current date/time.

    .PARAMETER LogFilePath
    Path to the log file

    .PARAMETER LogMessage
    Message to log

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param
    (
        # Path to the log file
        [Parameter(Mandatory)]
        [string]
        $LogFilePath,

        # Message to log
        [Parameter(Mandatory)]
        [string]
        $LogMessage
    )

    # format the message with current date and time
    $message = "$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' ) - $LogMessage"

    # append the message to the log file
    Add-Content -Path $LogFilePath -Value $message
}

function GetMetrics
{
    <#
    .SYNOPSIS
    This returns metrics about the computer performing the file locator search.  Metrics included are:
    - CPU % consumed
    - Memory % consumed
    - Disk space % consumed for each local disk
    - Number of files processed by DuplicateFileLocator

    .PARAMETER FileLocatorLogPath
    Path to the DuplicateFileLocator log (required to measure progress of search)

    .EXAMPLE
    GetMetrics -FileLocatorLogPath C:\Directory\Log.txt
    #>

    [CmdletBinding()]
    Param
    (
        # Path to the file locator log file (used to get progress)
        [Parameter(Mandatory)]
        [string]
        $FileLocatorLogPath
    )

    # get OS level metrics
    $dateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = [math]::Round((Get-Counter '\Processor(*)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Where-Object -FilterScript {$_.InstanceName -eq '_total'} | Select-Object -ExpandProperty CookedValue), 2)
    $mem = [math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 2)
    $disks = Get-CimInstance -Class 'Win32_LogicalDisk' -Filter "DriveType = '3'"

    # get progress from locator log file
    $logLine = Get-Content -Path $FileLocatorLogPath | Where-Object -FilterScript {$_ -like "*Processing file *"} | Select-Object -Last 1
    $null = $logLine -match "Processing file (\d*)"
    $filesProcessed = $Matches[1]

    # assemble output object
    $outputObject = [PSCustomObject]@{}
    Add-Member -InputObject $outputObject -NotePropertyName "DateTime" -NotePropertyValue $dateTime
    Add-Member -InputObject $outputObject -NotePropertyName "cpu %" -NotePropertyValue $cpu
    Add-Member -InputObject $outputObject -NotePropertyName "mem %" -NotePropertyValue $mem

    # add a column for each local disk
    foreach ($disk in $disks)
    {
        $freeSpace = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
        Add-Member -InputObject $outputObject -NotePropertyName "$( $disk.DeviceID ) free %" -NotePropertyValue "$freeSpace"
    }

    Add-Member -InputObject $outputObject -NotePropertyName "files processed" -NotePropertyValue $filesProcessed

    return $outputObject
}
