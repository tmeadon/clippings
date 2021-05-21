function ConvertFrom-IISW3CLog
{
    [CmdletBinding(DefaultParameterSetName = 'all')]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'firstOnly')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'lastOnly')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'all')]
        [Alias('PSPath')]
        [ValidateScript({Test-Path -Path $_})]
        [string[]]
        $Path,

        [Parameter(ParameterSetName = 'firstOnly')]
        [int]
        $First,

        [Parameter(ParameterSetName = 'lastOnly')]
        [int]
        $Last
    )

    Process
    {
        # use select-string to find all of the header lines in the log file and then pull out the field names into an array 
        $headerLineRegex = '^#'
        $headerLines = Select-String -Path $Path -Pattern $headerLineRegex
        $fieldNames = ($headerLines.Line | Select-String -Pattern '^#Fields:\s(?<fieldNames>.*)').Matches.Groups | Where-Object Name -eq 'fieldNames' | Select-Object -First 1 -ExpandProperty Value
        $fieldNames = $fieldNames.Split(' ')

        # read all the non-header lines into an array in memory and then determine which members of the array to output based on the supplied parameters

        $logLines = Select-String -Path $Path -Pattern $headerLineRegex -NotMatch
        $lineCount = $logLines.Count

        switch($PSCmdlet.ParameterSetName)
        {
            "firstOnly"
            {
                $indexRange = (0..($First - 1))
            }
            "lastOnly"
            {
                $indexRange = (($lineCount - $Last - 1)..($lineCount - 1))
            }
            "all"
            {
                $indexRange = (0..($lineCount - 1))
            }
        }
        
        # iterate through the index range calculated above to display the relevant lines to the user

        foreach ($i in $indexRange)
        {
            $fieldValues = $logLines[$i].Line.Split(' ')

            $output = @{}

            for ($j = 0; $j -lt $fieldValues.Length; $j++)
            {
                $output[$fieldNames[$j]] = $fieldValues[$j]
            }

            # convert the separate date and time key/values into a single key/value whose value has type of 'datetime'
            $output['datetime'] = [datetime]($output['date'] + "T" + $output['time'])
            $output.Remove('date')
            $output.Remove('time')

            [PSCustomObject]$output
        }
    }
}
