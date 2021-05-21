function Get-NasuniShares {
    [CmdletBinding()]
    param
    (
        
    )
    
    begin {}
    
    process
    {
        Invoke-NasuniApiCall -RelativeUri 'volumes/filers/shares/' -Method GET
    }
    
    end {}
}