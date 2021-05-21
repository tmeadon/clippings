function primes ($n) {

    $primes = 0..$n | ForEach-Object { $true }
    $primes[0] = $false
    $primes[1] = $false
    $limit = [math]::Sqrt($n)

    for ($i = 2; $i -le $limit; $i++)
    {
        if ($primes[$i])
        {
            for ($j = $i * 2; $j -le $n; $j += $i)
            {
                $primes[$j] = $false
            }
        }
    }

    for ($i = 0; $i -lt $primes.Count; $i++)
    {
        if ($primes[$i]) { $i }
    }
}


function head ($list) {
    return $list[0]
}

function tail ($list) {
    return $list[1..$list.length]
}

function recurseInto
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]
        $List,

        [Parameter()]
        [string]
        $fn
    )

    if ($list.length -ge 1) {
        & $fn(head($list))
        recurseInto -List (tail($list)) -fn $fn
    }
}



function print ($arg) { write-output "print $arg" }


primes(100)