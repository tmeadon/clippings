enum Ensure
{
    Present
    Absent    
}

[DscResource()]
class MyFolder
{
    [DscProperty(Key)] [string] $Path
    [DscProperty(Mandatory)] [Ensure] $Ensure

    [MyFolder] Get()
    {
        if (Test-Path -Path $this.Path)
        {
            $this.Ensure = [Ensure]::Present
        }
        else
        {
            $this.Ensure = [Ensure]::Absent    
        }

        return $this
    }

    [Bool] Test()
    {
        $exists = Test-Path -Path $this.Path

        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $exists
        }
        else
        {
            return (-not $exists)
        }
    }

    [Void] Set()
    {
        if ($this.Ensure -eq [Ensure]::Present)
        {
            $null = New-Item -Path $this.Path -ItemType Directory
        }
        elseif ($this.Ensure -eq [Ensure]::Absent)
        {
            Remove-Item -Path $this.Path -Force
        }
    }
}