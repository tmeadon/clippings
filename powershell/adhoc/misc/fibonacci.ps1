

function fib ([int]$n)
{
    $fibList = @()

    for ($i = 0; $i -lt $n; $i++)
    {
        if ($i -lt 2)
        {
            $fibList += 1
        }
        else
        {
            $fibList += ($fibList[$i - 1] + $fibList[$i - 2])
        }
    }

    $fibList
}

fib([int]40)


function fibRecurse ($n) {
    
    if ($n -le 2)
    {
        return 1
    }
    else
    {
        $fib = (fibRecurse($n - 1)) + (fibRecurse($n - 2))
        return $fib
    }

}

fibRecurse(100)

function fibSpaceOptimised ($n) {
    
    $a = 0
    $b = 1

    if ($n -eq 0)
    {
        return 0
    }
    
    for ($i = 2; $i -le $n; $i++)
    {
        $tmp = $a + $b
        $a = $b
        $b = $tmp
    }

    return $b
}

fibSpaceOptimised(1)