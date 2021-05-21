function add
{
    param
    (
        [int] $a,
        [int] $b
    )

    # if ($b -eq 11) { $b = 13 }

    return $a + $b
}

function run
{
    return add -a 2 -b 10
}
