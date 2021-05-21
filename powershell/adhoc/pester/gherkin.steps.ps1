Given 'we have a test directory containing files and directories' {
    New-Item -Path 'testDirectory' -ItemType Directory
    New-Item -Path 'testDirectory\dir' -ItemType Directory
    New-Item -Path 'testDirectory\file.txt' -ItemType File
    (Get-ChildItem -Path 'testDirectory').Count | Should Be 2
}

AfterEachScenario {
    Remove-Item -Path 'testDirectory' -Recurse -Force
}

When 'we call Get-ChildItem inside our test directory with the -File parameter' {
    $result = Get-ChildItem -Path 'testDirectory' -File
}

Then 'only file items are returned' {
    $directories = $result.Where({$_.PSIsContainer})
    $directories.Count | Should Be 0
}

When 'we call Get-ChildItem inside our test directory with the -Directory parameter' {
    $result = Get-ChildItem -Path 'testDirectory' -Directory
}

Then 'only directory items are returned' {
    $files = $result.Where({! ($_.PSIsContainer)})
    $files.Count | Should Be 0
}