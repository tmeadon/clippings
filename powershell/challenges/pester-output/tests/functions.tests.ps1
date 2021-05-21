# load functions and classes
$helperFolder = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath 'helpers'
. $helperFolder\functions.ps1
. $helperFolder\classes.ps1

# produce example output
& "$PSScriptRoot\New-ExampleOutput.ps1"
$nunitXml = [xml](Get-Content -Path "$PSScriptRoot\example-nunit.xml")
$junitXml = [xml](Get-Content -Path "$PSScriptRoot\example-junit.xml")

# store some non valid xml
$badXml = [xml] @'
<badXml>
    <foo>
        <bar>
        </bar>
    </foo>
</badXml>
'@

Describe "Get-TestOutputFormatType" {

    $testCases = @(
        @{
            xml = $nunitXml
            result = [SupportedTestOutputFormats]::NUnit
        }
        @{
            xml = $junitXml
            result = [SupportedTestOutputFormats]::JUnit
        }
    )

    It "should return the correct test format" -TestCases $testCases {
        param ($xml, $result)
        Get-TestOutputFormatType -XmlDocument $xml | Should Be $result
    }

}

Describe "Test-SupportedOutputFormat tests" {

    It "should return true if nunit output xml is supplied" {
        Test-SupportedOutputFormat -XmlDocument $nunitXml | Should -Be $true
    }

    It "should return false if junit output xml is supplied" {
        Test-SupportedOutputFormat -XmlDocument $junitXml | Should -Be $true
    }

    It "should return false if non-test output format xml is supplied" {
        Test-SupportedOutputFormat -XmlDocument $badXml | Should -Be $false
    }

    It "should throw if non-xml is supplied" {
        { Test-SupportedOutputFormat -XmlDocument "abc" } | Should throw
    }

}

Describe "Convert-NUnitResultToPesterResult" {

    $testCases = @(
        @{
            inputResult = 'Success'
            inputSuccess = 'True'
            expected = 'Passed'
        }
        @{
            inputResult = 'Failure'
            inputSuccess = 'False'
            expected = 'Failed'
        }
        @{
            inputResult = 'Ignored'
            inputSuccess = 'True'
            expected = 'Skipped'
        }
        @{
            inputResult = 'Inconclusive'
            inputSuccess = 'True'
            expected = 'Pending'
        }
        @{
            inputResult = 'Inconclusive'
            inputSuccess = 'False'
            expected = 'Inconclusive'
        }
    )

    It "should convert from NUnit style results to Pester style results successfully" -TestCases $testCases {
        Param ($inputResult, $inputSuccess, $expected)
        Convert-NUnitResultToPesterResult -InputResult $inputResult -InputSuccess $inputSuccess | Should -Be $expected
    }
}

Describe "Get-Tests tests" {

    $testCases = @(
        @{
            testName = "is a test outside of a context block (example-tests-1)"
            describeBlock = "example-tests-1"
            contextBlock = $null
            scriptFile = "$PSScriptRoot\exampleTests.ps1"
            testResult = 'Passed'
        }
        @{
            testName = "should be skipped (example-tests-1)"
            describeBlock = "example-tests-1"
            contextBlock = "context2"
            scriptFile = "$PSScriptRoot\exampleTests.ps1"
            testResult = 'Skipped'
        }
        @{
            testName = "should fail (example-tests-2)"
            describeBlock = "example-tests-2"
            contextBlock = "context1"
            scriptFile = "$PSScriptRoot\exampleTests.ps1"
            testResult = 'Failed'
        }
    )

    Context "NUnit Tests" {

        $result = (Get-Tests -XmlDocument $nunitXml)

        It "should return a list containing the correct number of tests" {
            $result.Count | Should Be 12
        }

        It "should return the correct context block for each test" -TestCases $testCases {
            param ($testName, $contextBlock)
            $result.Where({$_.testName -eq $testName}).contextBlock | Should Be $contextBlock      
        }

        It "should return the correct describe blocks for each test" -TestCases $testCases {
            param ($testName, $describeBlock)
            $result.Where({$_.testName -eq $testName}).describeBlock | Should Be $describeBlock 
        }

        It "should return the correct pester script file for each test" -TestCases $testCases {
            param ($testName, $scriptFile)
            $result.Where({$_.testName -eq $testName}).pesterScriptFile | Should Be $scriptFile 
        }

        It "should return the correct result for each test" -TestCases $testCases {
            param ($testName, $testResult)
            $result.Where({$_.testName -eq $testName}).testResult | Should Be $testResult 
        }
    }

    Context "JUnit Tests" {

        $result = (Get-Tests -XmlDocument $junitXml)

        It "should return a list containing the correct number of tests" {
            $result.Count | Should Be 12
        }

        It "should return the correct context block for each test" -TestCases $testCases {
            param ($testName, $contextBlock)
            $result.Where({$_.testName -eq $testName}).contextBlock | Should Be $contextBlock      
        }

        It "should return the correct describe blocks for each test" -TestCases $testCases {
            param ($testName, $describeBlock)
            $result.Where({$_.testName -eq $testName}).describeBlock | Should Be $describeBlock 
        }

        It "should return the correct pester script file for each test" -TestCases $testCases {
            param ($testName, $scriptFile)
            $result.Where({$_.testName -eq $testName}).pesterScriptFile | Should Be $scriptFile 
        }

        It "should return the correct result for each test" -TestCases $testCases {
            param ($testName, $testResult)
            $result.Where({$_.testName -eq $testName}).testResult | Should Be $testResult 
        }
    }
}

Describe "Get-TestRunDuration" {

    $testCases = @(
        @{
            xml = $nunitXml
            duration = $nunitXml.'test-results'.'test-suite'.time
        }
        @{
            xml = $junitXml
            duration = $junitXml.testsuites.time 
        }
    )

    It "returns the correct duration for NUnit XML" -TestCases $testCases {
        param ($xml, $duration)
        Get-TestRunDuration -XmlDocument $xml | Should Be $duration
    }

}

Describe "Get-TestsSummaryLine" {

    # Mock -CommandName "Write-Host"

    # $testCases = @(
    #     @{
    #         pesterTestCases = @(
    #             [PesterTestCase]::new('a', 'b', 'c', [PesterTestResults]::Passed)
    #             [PesterTestCase]::new('d', 'e', 'f', [PesterTestResults]::Passed)
    #         )
    #         passedTests = 2
    #         passedTextColour = 'Green'
    #     }
    #     @{
    #         pesterTestCases = @(
    #             [PesterTestCase]::new('a', 'b', 'c', [PesterTestResults]::Passed)
    #             [PesterTestCase]::new('d', 'e', 'f', [PesterTestResults]::Failed)
    #         )
    #         passedTests = 1
    #         passedTextColour = 'White'
    #     }
    # )

    # It "should write the passed section of the summary correctly" -TestCases $testCases {
    #     param ([PesterTestCase[]] $pesterTestCases, $passedTests, $passedTextColour)
    #     Write-TestsSummaryLine -PesterTestCases @([PesterTestCase]::new('d', 'e', 'f', [PesterTestResults]::Passed))
    #     $writeHostParamFilter = { $Object -eq ("Tests Passed: 4, " -f $passedTests) -and $ForegroundColor -eq $passedTests -and $NoNewLine -eq $true }  
    #     Assert-MockCalled -CommandName "Write-Host" -Times 1 -ParameterFilter $writeHostParamFilter
    # }
}

Describe "Write-PesterOutput" {
    
}

# clean up
Get-ChildItem -Path $PSScriptRoot -Filter *.xml | Remove-Item