Describe example-tests-1 {

    It "is a test outside of a context block (example-tests-1)" {
        $true | Should be $true
    }    

    Context context1 {

        It "should pass (example-tests-1)" {
            $true | Should Be $true
        }

        It "should fail (example-tests-1)" {
            $true | Should Be $false
        }
    
    }

    Context context2 {

        It "should be skipped (example-tests-1)" {
            Set-ItResult -Skipped
        }

        It "should be pending (example-tests-1)" {
            Set-ItResult -Pending
        }

        It "should be inconclusive (example-tests-1)" {
            Set-ItResult -Inconclusive
        }

    }
}

Describe example-tests-2 {

    It "is a test outside of a context block (example-tests-2)" {
        $true | Should be $true
    }    

    Context context1 {

        It "should pass (example-tests-2)" {
            $true | Should Be $true
        }

        It "should fail (example-tests-2)" {
            $true | Should Be $false
        }
    
    }

    Context context2 {

        It "should be skipped (example-tests-2)" {
            Set-ItResult -Skipped
        }

        It "should be pending (example-tests-2)" {
            Set-ItResult -Pending
        }

        It "should be inconclusive " {
            Set-ItResult -Inconclusive
        }

    }
}
