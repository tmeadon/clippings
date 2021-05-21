function New-AzureVm {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # VM name
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $VmName,

        # Resource group name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ResourceGroupName,

        # VM location
        [Parameter(Mandatory)]
        [string]
        $Location,

        # VNet name
        [Parameter(Mandatory, ParameterSetName = "NewVnet")]
        [string]
        $VnetName,

        # Subnet name
        [Parameter(ParameterSetName = "NewVnet")]
        [string]
        $SubnetName = "subnet-1",

        # ID for existing subnet to deploy VM into
        [Parameter(Mandatory, ParameterSetName = "ExistingVnet")]
        [string]
        $ExistingSubnetId,

        # VM OS
        [Parameter(Mandatory)]
        [ValidateSet('Windows2019')]
        [string]
        $VmOs,

        # Public IP name
        [Parameter()]
        [switch]
        $AddPublicIp,

        # Admin username for the VM
        [Parameter(Mandatory)]
        [string]
        $AdminUsername,

        # Admin password for the VM
        [Parameter(Mandatory)]
        [securestring]
        $AdminPassword
    )

    begin {}

    process {
        # figure out which template to call and which image profile to use based on the supplied os type
        switch ($VmOs) {
            "Windows2019" {
                $templateName = 'vm-windows.deploy.json'
                $imageProfile = @{
                    publisher = "MicrosoftWindowsServer"
                    offer = "WindowsServer"
                    sku = "2019-Datacenter"
                    version = "latest"
                }
            }
        }

        $templatePath = Join-Path -Path $script:armTemplateDirectory -ChildPath $templateName

        # build the deployment parameters based on the chosen parameter set name
        $deployParams = @{
            ResourceGroupName = $ResourceGroupName
            TemplateFile = $templatePath
            vmName = $VmName
            location = $Location
            imageProfile = $imageProfile
            addPublicIp = [bool] $AddPublicIp
            adminUsername = $AdminUsername
            adminPassword = $AdminPassword
        }

        if ($PSCmdlet.ParameterSetName -eq "NewVnet") {
            $deployParams['newVnetName'] = $VnetName
            $deployParams['newSubnetName'] = $SubnetName
        }
        elseif ($PSCmdlet.ParameterSetName -eq "ExistingVnet") {
            $deployParams['existingSubnetId'] = $ExistingSubnetId
        }

        # start the deployment
        if ($PSCmdlet.ShouldProcess("Resource Group: $($deployParams['ResourceGroupName'])")) {
            $deployment = New-AzResourceGroupDeployment @deployParams

            # return deployment status
            [PSCustomObject]@{
                VMName = $VmName
                ResourceGroupName = $ResourceGroupName
                DeploymentStatus = $deployment.ProvisioningState
                DeploymentParameters = $deployment.Parameters
            }
        }
        
    }

    end {}
}