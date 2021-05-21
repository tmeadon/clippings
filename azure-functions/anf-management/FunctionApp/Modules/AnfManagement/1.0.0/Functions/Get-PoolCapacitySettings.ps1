function Get-PoolCapacitySettings
{
    [CmdletBinding()]
    param
    (
        # Hashtable containing the Pool's resource tags
        [Parameter()]
        [hashtable]
        $PoolTags
    )

    begin {}

    process
    {
        $maxSizeTb = $anfCapacityDefaults.poolMaxSizeTb
        $minSizeTb = $anfCapacityDefaults.poolMinSizeTb

        if ($PoolTags.MinPoolSizeTb)
        {
            if (([int]$PoolTags.MinPoolSizeTb -ge 4) -and ([int]$PoolTags.MinPoolSizeTb -le 512000))
            {
                $minSizeTb = [int]$PoolTags.MinPoolSizeTb
            }
        }

        if ($PoolTags.MaxPoolSizeTb)
        {
            if (([int]$PoolTags.MaxPoolSizeTb -ge 4) -and ([int]$PoolTags.MaxPoolSizeTb -le 512000))
            {
                $maxSizeTb = [int]$PoolTags.MaxPoolSizeTb
            }
        }

        [PSCustomObject]@{
            MaxSize = $maxSizeTb * 1TB
            MinSize = $minSizeTb * 1TB
        }
    }

    end {}
}
