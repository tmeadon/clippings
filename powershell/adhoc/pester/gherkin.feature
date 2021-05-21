Feature: You can choose whether to list only directories or only files

Background: Set up the directory
    Given we have a test directory containing files and directories

Scenario: Choose to list only files
    When we call Get-ChildItem inside our test directory with the -File parameter
    Then only file items are returned

Scenario: Choose to list only directories
    When we call Get-ChildItem inside our test directory with the -Directory parameter
    Then only directory items are returned