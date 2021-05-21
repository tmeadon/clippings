# dot source
. $PSScriptRoot\function.ps1

Describe 'add tests' {
    
    $aArr = 1, 2, 3, 4
    $bArr = 10, 11, 12, 13

    foreach ($a in $aArr)
    {
        foreach ($b in $bArr)
        {
            It "should return $($a + $b) when supplying a = $a and b = $b" {
                (add -a $a -b $b) | Should -Be ($a + $b)
            }
        }
    }
    
}

Describe 'run tests' {

    it 'should return 12' {
        
        Mock 'add' -MockWith { 12 }

        run | Should -Be 12

    }

}
