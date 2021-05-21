function Get-TestOutputFormatType {
    [CmdletBinding()]
    param (
        # XML document object containing test output 
        [Parameter(Mandatory)]
        [xml]
        $XmlDocument
    )
    
    begin {}
    
    process {
        if ($XmlDocument.'test-results'.noNamespaceSchemaLocation -like "nunit*") {
            return [SupportedTestOutputFormats]::NUnit
        }
        elseif ($XmlDocument.testsuites.noNamespaceSchemaLocation -like "junit*") {
            return [SupportedTestOutputFormats]::JUnit
        }
        else {
            throw [System.NotImplementedException]::new("XML is not in a supported output format")
        }
    }
    
    end {}
}

function Test-SupportedOutputFormat {
    [CmdletBinding()]
    param (
        # XML document object containing test output 
        [Parameter(Mandatory)]
        [xml]
        $XmlDocument
    )
    
    begin {}
    
    process {

        try {
            Get-TestOutputFormatType -XmlDocument $XmlDocument | Out-Null
            return $true
        }
        catch {
            return $false
        }
    }
    
    end {}
}

function Convert-NUnitResultToPesterResult {
    [CmdletBinding()]
    param (
        # 'Result' property of the NUnit test case
        [Parameter(Mandatory)]
        [ValidateSet('Success','Failure','Ignored','Inconclusive')]
        [string]
        $InputResult,

        # 'Success' property of the NUnit test case
        [Parameter(Mandatory)]
        [ValidateSet('True','False')]
        [string]
        $InputSuccess
    )
    
    begin {}
    
    process {        
        switch ($InputResult) {
            'Success' { return [PesterTestResults]::Passed }
            'Failure' { return [PesterTestResults]::Failed }
            'Ignored' { return [PesterTestResults]::Skipped }
            'Inconclusive' {
                switch ($InputSuccess) {
                    'True' { return [PesterTestResults]::Pending }
                    'False' { return [PesterTestResults]::Inconclusive }

                }
            }
        }
    }
    
    end {}
}

function Get-Tests {
    [CmdletBinding()]
    param (
        # XML document object containing test output 
        [Parameter(Mandatory)]
        [ValidateScript(
            {
                Test-SupportedOutputFormat -XmlDocument $_
            }
        )]
        [xml]
        $XmlDocument
    )
    
    begin {}
    
    process {

        $tests = @()

        $testOutputType = Get-TestOutputFormatType -XmlDocument $XmlDocument

        switch ($testOutputType) {

            ([SupportedTestOutputFormats]::NUnit).ToString() {

                $testFiles = $XmlDocument.'test-results'.'test-suite'.results.'test-suite'

                foreach ($file in $testFiles) {
    
                    foreach ($describe in $file.results.'test-suite') {
    
                        foreach ($case in $describe.results.'test-case') {
                            $pesterResult = Convert-NUnitResultToPesterResult -InputResult $case.result -InputSuccess $case.success
                            $tests += [PesterTestCase]::new($case.description, $describe.name, $file.name, $pesterResult)
                        }
    
                        foreach ($context in $describe.results.'test-suite') {
    
                            foreach ($case in $context.results.'test-case') {
                                $pesterResult = Convert-NUnitResultToPesterResult -InputResult $case.result -InputSuccess $case.success
                                $tests += [PesterTestCase]::new($case.description, $context.description, $describe.name, $file.name, $pesterResult)
                            }
    
                        }               
                    }
                }
            }

            ([SupportedTestOutputFormats]::JUnit).ToString() {

                $testCases = $XmlDocument.testsuites.testsuite.testcase

                foreach ($case in $testCases) {

                    $nameSplit = $case.name.Split(".")
                    
                    switch ($nameSplit.Count) {                  
                        2 {
                            $tests += [PesterTestCase]::new($nameSplit[1], $nameSplit[0], $case.classname, $case.status)
                        }
                        3 {
                            $tests += [PesterTestCase]::new($nameSplit[2], $nameSplit[1], $nameSplit[0], $case.classname, $case.status)
                        }
                    }
                }
            }
        }

        return $tests
    }
    
    end {}
}

function Get-TestRunDuration {
    [CmdletBinding()]
    param (
        # XML document object containing test output 
        [Parameter(Mandatory)]
        [ValidateScript(
            {
                Test-SupportedOutputFormat -XmlDocument $_
            }
        )]
        [xml]
        $XmlDocument
    )
    
    begin {}
    
    process {

        $outputType = Get-TestOutputFormatType -XmlDocument $XmlDocument

        switch ($outputType) {
            ([SupportedTestOutputFormats]::NUnit).ToString() { return $XmlDocument.'test-results'.'test-suite'.time }
            ([SupportedTestOutputFormats]::JUnit).ToString() { return $XmlDocument.testsuites.time }
        }
 
    }
    
    end {}
}

function Write-TestsSummaryLine {
    [CmdletBinding()]
    param (
        # Collection of PesterTestCase objects to summarise
        [Parameter(Mandatory)]
        [PesterTestCase[]]
        $PesterTestCases
    )
    
    begin {}
    
    process {

        $totalTests = $PesterTestCases.Count
        $passedTests = $PesterTestCases.Where({$_.testResult -eq 'Passed'}).Count
        $failedTests = $PesterTestCases.Where({$_.testResult -eq 'Failed'}).Count
        $skippedTests = $PesterTestCases.Where({$_.testResult -eq 'Skipped'}).Count
        $pendingTests = $PesterTestCases.Where({$_.testResult -eq 'Pending'}).Count
        $inconclusiveTests = $PesterTestCases.Where({$_.testResult -eq 'Inconclusive'}).Count

        if ($totalTests -eq $passedTests) {
            $textColour = "Green"
        }
        else {
            $textColour = "White"
        }

        Write-Host -Object ("Tests Passed: {0}, " -f $passedTests) -ForegroundColor $textColour -NoNewline

        if ($failedTests -gt 0) {
            $textColour = "Red"
        }
        else {
            $textColour = "White"
        }

        Write-Host -Object ("Failed: {0}, " -f $failedTests) -ForegroundColor $textColour -NoNewline

        if ($skippedTests -gt 0) {
            $textColour = "Yellow"
        }
        else {
            $textColour = "White"
        }

        Write-Host -Object ("Skipped: {0}, " -f $skippedTests) -ForegroundColor $textColour -NoNewline
        Write-Host -Object ("Pending: {0}, " -f $pendingTests) -ForegroundColor White -NoNewline
        Write-Host -Object ("Inconclusive: {0}, " -f $inconclusiveTests) -ForegroundColor White

    }
    
    end {}
}

function Write-PesterOutput {
    [CmdletBinding()]
    param (
        # XML document object containing test output 
        [Parameter(Mandatory)]
        [ValidateScript(
            {
                Test-SupportedOutputFormat -XmlDocument $_
            }
        )]
        [xml]
        $XmlDocument
    )
    
    begin {}
    
    process {

        # convert the XML into an array of PesterTestCase objects

        $PesterTestCases = Get-Tests -XmlDocument $XmlDocument
        
        # iterate through the individual script files

        $scriptFiles = $PesterTestCases.pesterScriptFile | Sort-Object -Unique

        foreach ($file in $scriptFiles) {

            Write-Host -Object "`nExecuting script $file" -ForegroundColor Green

            # iterate through the individual describe blocks

            $describeBlocks = $PesterTestCases.Where({$_.pesterScriptFile -eq $file}).describeBlock | Sort-Object -Unique

            foreach ($describe in $describeBlocks) {

                Write-Host -Object "`n  Describing $describe" -ForegroundColor Green

                # print any test cases directly underneath this describe (i.e. not in a context block)

                $testCases = $PesterTestCases.Where({$_.pesterScriptFile -eq $file -and $_.describeBlock -eq $describe -and $null -eq $_.contextBlock})

                foreach ($case in $testCases) {                    
                    Write-Host -Object ("    {0} {1}" -f $case.OutputLinePrefix, $case.testName) -ForegroundColor $case.OutputColour
                }

                # iterate through the individual context blocks

                $contextBlocks = $PesterTestCases.Where({$_.pesterScriptFile -eq $file -and $_.describeBlock -eq $describe -and $null -ne $_.contextBlock}).contextBlock | Sort-Object -Unique

                foreach ($context in $contextBlocks) {

                    Write-Host -Object "`n    Context $context" -ForegroundColor Green

                    # iterate through the individual tests within the context block

                    $testCases = $PesterTestCases.Where({$_.pesterScriptFile -eq $file -and $_.describeBlock -eq $describe -and $_.contextBlock -eq $context})

                    foreach ($case in $testCases) {                    
                        Write-Host -Object ("      {0} {1}" -f $case.OutputLinePrefix, $case.testName) -ForegroundColor $case.OutputColour
                    }

                }

            }

        }

        # write the summary lines

        Write-Host -Object ("Tests completed in {0}s" -f (Get-TestRunDuration -XmlDocument $XmlDocument)) -ForegroundColor White
        Write-Host -Object (Write-TestsSummaryLine -PesterTestCases $PesterTestCases)

    }
    
    end {}
}

