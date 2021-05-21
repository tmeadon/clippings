function Get-AzureVmIpAddresses {
    [CmdletBinding()]
    param (
        # Name of the VM to get the IP address for
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        # Network profile object for the VM (contained in the object returned by Get-AzVM)
        [Parameter(ValueFromPipelineByPropertyName)]
        [Microsoft.Azure.Management.Compute.Models.NetworkProfile]
        $NetworkProfile
    )

    begin {}

    process {
        # get the ID(s) for the attached NICs
        if ($NetworkProfile) {
            $nicIds = $NetworkProfile.NetworkInterfaces.Id
        }
        else {
            $nicIds = (Get-AzVM -Name $Name).NetworkProfile.NetworkInterfaces.Id
        }

        # get the IPs from the NICs
        $privateIps = @()
        $publicIps = @()
        foreach ($id in $nicIds) {
            $nic = Get-AzNetworkInterface -ResourceId $id
            $privateIps += $nic.IpConfigurations.PrivateIpAddress
            if ($nic.IpConfigurations.PublicIpAddress.Id) {
                $publicIps += $nic.IpConfigurations.PublicIpAddress.Id | ForEach-Object -Process {(Get-AzResource -ResourceId $_ | Get-AzPublicIpAddress).IpAddress}
            }
        }

        # return an object containing the VM's name and its private IPs
        [PSCustomObject]@{
            VMName = $Name
            PrivateIPs = $privateIps
            PublicIPs = $publicIps
        }
    }

    end {}
}
