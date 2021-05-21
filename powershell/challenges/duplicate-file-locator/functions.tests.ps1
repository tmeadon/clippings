# . (Join-Path -Path $PSScriptRoot -ChildPath 'functions.ps1')

Describe "Testing helper functions" {

    $testDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    Mock -CommandName Get-Date -MockWith { return $testDate }

    Context "Testing Logger function" {

        $testMessage = "message"
        $testLogFilePath = "testLogFilePath"
        $expectedMessage = "$( $testDate ) - $testMessage"

        Mock -CommandName Add-Content -ParameterFilter { ($Path -eq $testLogFilePath) -and ($Value -eq $expectedMessage) } -MockWith {} 
        
        It "LogMessage parameter should be mandatory" {
            (Get-Command -Name Logger).Parameters['LogMessage'].Attributes.Mandatory | Should -Be $true
        }

        It "LogPath parameter should be mandatory" {
            (Get-Command -Name Logger).Parameters['LogFilePath'].Attributes.Mandatory | Should -Be $true
        }

        It "calls Add-Content with the correct parameters" {
            Logger -LogMessage $testMessage -LogFilePath $testLogFilePath
            Assert-MockCalled -CommandName Add-Content -Exactly -Times 1
        }

    }

    Context "Testing GetMetrics function" {

        $testFileLocatorLogPath = "testLogPath"

        $testDiskInfo = @(
            [PSCustomObject]@{
                DeviceId = "C:"
                Size = 100
                FreeSpace = 33.33
            },
            [PSCustomObject]@{
                DeviceId = "D:"
                Size = 100
                FreeSpace = 25
            }
        )

        Mock -CommandName Get-CimInstance -ParameterFilter { $ClassName -eq "Win32_OperatingSystem" } -MockWith {
            return @{
                TotalVisibleMemorySize = 16655108
                FreePhysicalMemory = 16655108 / 3
            }
        }

        Mock -CommandName Get-CimInstance -ParameterFilter { $ClassName -eq "Win32_LogicalDisk" } -MockWith {
            return $testDiskInfo
        }

        Mock -CommandName Get-Counter -ParameterFilter { $Counter -eq '\Processor(*)\% Processor Time' } -MockWith {
            return [PSCustomObject]@{
                CounterSamples = @(
                    [PSCustomObject]@{
                        InstanceName = '_total'
                        CookedValue = '6.9918681330749'
                    }
                )
            }
        }

        Mock -CommandName Get-Content -ParameterFilter { $Path -eq $testFileLocatorLogPath } -MockWith {
            return "Processing file 5"
        }

        $result = GetMetrics -FileLocatorLogPath $testFileLocatorLogPath

        It "FileLocatorLogPath parameter should be mandatory" {
            (Get-Command -Name GetMetrics).Parameters['FileLocatorLogPath'].Attributes.Mandatory | Should -Be $true
        }

        It "Should return an object with a property called DateTime containing the current date" {
            $result.DateTime | Should -BeExactly $testDate
        }

        It "Should return an object with a property called 'cpu %' with a value of 6.99" {
            $result.'cpu %' | Should -BeExactly 6.99
        }

        It "Should return an object with a property called 'mem %' with a value of 33.33" {
            $result.'mem %' | Should -BeExactly 33.33
        }

        foreach ($disk in $testDiskInfo)
        {
            It "Should return an object with a property called '$( $disk.DeviceId ) free %' with a value of $( $disk.FreeSpace )" {
                $result."$($disk.DeviceId) free %" | Should -BeExactly $disk.FreeSpace
            }
        }

        It "Should return an object with a property called files processed with a value of 5" {
            $result.'files processed' | Should -BeExactly 5
        }

    }

    Context "Testing CreateTextReport function" {

        $testTextReportPath = (Get-Location).Path

        $testFileList = @(
            '.\file1.txt',
            '.\file2.txt',
            '.\file3.txt'
        )

        Mock -CommandName 'Remove-Item' -MockWith {} -ParameterFilter { $TextReportPath -eq $testTextReportPath -and $Force }
        Mock -CommandName "Add-Content" -MockWith {}

        It "FileList parameter should be mandatory" {
            (Get-Command -Name CreateTextReport).Parameters['FileList'].Attributes.Mandatory | Should -Be $true
        }

        It "TextReportPath parameter should be mandatory" {
            (Get-Command -Name CreateTextReport).Parameters['TextReportPath'].Attributes.Mandatory | Should -Be $true
        }

        It "Should remove an existing report if there is one" {
            CreateTextReport -TextReportPath $testTextReportPath -FileList $testFileList
            Assert-MockCalled -CommandName 'Remove-Item' -Times 1
        }

    }

}
