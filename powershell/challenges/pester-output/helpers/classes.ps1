enum SupportedTestOutputFormats {
    NUnit
    JUnit
}

enum PesterTestResults {
    Passed
    Failed
    Skipped
    Pending
    Inconclusive
}

class PesterTestCase {

    [string] $testName
    [string] $contextBlock
    [string] $describeBlock
    [string] $pesterScriptFile
    [PesterTestResults] $testResult
    [string] $outputColour
    [string] $outputLinePrefix

    PesterTestCase([string] $TestName, [string] $ContextBlock, [string] $DescribeBlock, [string] $PesterScriptFile, [PesterTestResults] $TestResult) {
        $this.testName = $TestName
        $this.contextBlock = $ContextBlock
        $this.describeBlock = $DescribeBlock
        $this.pesterScriptFile = $PesterScriptFile
        $this.testResult = $TestResult

        $this.SetOutputColour($this.testResult)
        $this.SetOutputLinePrefix($this.testResult)
    }

    PesterTestCase([string] $TestName, [string] $DescribeBlock, [string] $PesterScriptFile, [PesterTestResults] $TestResult) {
        $this.testName = $TestName
        $this.describeBlock = $DescribeBlock
        $this.pesterScriptFile = $PesterScriptFile
        $this.testResult = $TestResult

        $this.SetOutputColour($this.testResult)
        $this.SetOutputLinePrefix($this.testResult)
    }

    [void] SetOutputColour([PesterTestResults] $result) {

        switch ($result) {
            ([PesterTestResults]::Passed).ToString() { 
                $this.outputColour = 'Green'
                break
            }
            ([PesterTestResults]::Failed).ToString() {
                $this.outputColour = 'Red'
                break
            }
            ([PesterTestResults]::Skipped).ToString() {
                $this.outputColour = 'Yellow'
                break
            }
            default {
                $this.outputColour = 'White'
            }
        }

    }

    [void] SetOutputLinePrefix([PesterTestResults] $result) {

        switch ($result) {
            ([PesterTestResults]::Passed).ToString() { 
                $this.outputLinePrefix = '[+]' 
                break 
            }
            ([PesterTestResults]::Failed).ToString() { 
                $this.outputLinePrefix = '[-]'
                break
            }
            ([PesterTestResults]::Skipped).ToString() { 
                $this.outputLinePrefix = '[!]'
                break
            }
            default {
                $this.outputLinePrefix = '[?]' 
            }
        }

    }

}
