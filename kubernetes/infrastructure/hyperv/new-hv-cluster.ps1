#Requires -Version '7.0.0'
#Requires -Module 'Hyper-V'

[CmdletBinding()]
param
(
    [string] $clusterName,
    [int] $numWorkers,
    [int] $numNfsHosts = 1,
    [switch] $noImageGeneration
)

Push-Location $PSScriptRoot

# check the cluster name isn't already in use
if (Get-VM -Name "*$clusterName*" -ErrorAction SilentlyContinue) { throw "cluster name '$clusterName' is already in use" }

Write-Verbose -Message "Creating cluster $clusterName"

# generate VM info
$nodes = @{
    master = [PSCustomObject]@{
        name = "$clusterName-master"
        ipaddress = ''
    }
    workers = @()
    nfsHosts = @()
}

for ($i = 1; $i -le $numWorkers; $i++)
{
    $nodes.workers += [PSCustomObject]@{
        name = "$clusterName-worker$i"
        ipaddress = ''
    }
}

for ($i = 1; $i -le $numNfsHosts; $i++)
{
    $nodes.nfsHosts += [PSCustomObject]@{
        name = "$clusterName-nfs$i"
        ipaddress = ''
    }
}

# store path to packer image directory
$packerTemplateRootPath = "$PSScriptRoot\..\..\..\packer\templates"
$kubePackerImageDirectoryPath = "$packerTemplateRootPath\kubernetes"
$nfshostPackerImageDirectoryPath = "$packerTemplateRootPath\nfs-host"

# generate a fresh image for the VMs
if (-not $noImageGeneration)
{
    Write-Verbose -Message "Generating machine image artifacts"
    $kubePackerImageDirectoryPath, $nfshostPackerImageDirectoryPath | ForEach-Object -Parallel { & "$_\build.ps1" } | Out-Null
}

# start background jobs for creating the VMs
Write-Verbose -Message "Deploying VMs"
$masterDeployJob = Start-Job -ScriptBlock { & "$using:kubePackerImageDirectoryPath\new-vm.ps1" -name $using:nodes.master.name }
$workerDeployJob = Start-Job -ScriptBlock {
    $kubePackerImageDirectoryPath = $using:kubePackerImageDirectoryPath
    $using:nodes.workers | ForEach-Object -Parallel { & "$using:kubePackerImageDirectoryPath\new-vm.ps1" -name $_.name } -ThrottleLimit 2
}
$nfsHostDeployJob = Start-Job -ScriptBlock {
    $nfshostPackerImageDirectoryPath = $using:nfshostPackerImageDirectoryPath
    $using:nodes.nfsHosts | ForEach-Object -Parallel { & "$using:nfshostPackerImageDirectoryPath\new-vm.ps1" -name $_.name } -ThrottleLimit 2
}

# start configuring the master as soon as the VM is ready
$nodes.master.ipaddress = Wait-Job -Id $masterDeployJob.Id | Receive-Job | Select-Object -ExpandProperty IPAddress
Write-Verbose -Message "Configuring master node and initialising cluster"
ssh -i "$kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $nodes.master.ipaddress )" "/opt/image-files/scripts/configure-node.sh -h $( $nodes.master.name ) -i $( $nodes.master.ipaddress ) -t master" | Out-Null
ssh -i "$kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $nodes.master.ipaddress )" "/opt/image-files/scripts/initialise-cluster.sh" 3> $null | Out-Null

# get the cluster join command from the master node
$clusterJoinCommand = ssh -i "$kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $nodes.master.ipaddress )" "kubeadm token create --print-join-command"

# next configure the worker nodes and add them to the cluster
$creationJobOutput = Wait-Job -Id $workerDeployJob.Id | Receive-Job

for ($i = 0; $i -lt $nodes.workers.Length; $i++)
{
    $nodes.workers[$i].ipaddress = $creationJobOutput.Where({$_.name -eq $nodes.workers[$i].name}).ipaddress
}

Write-Verbose -Message 'Configuring nodes and adding to cluster'

$nodes.workers | ForEach-Object -Parallel {
    ssh -i "$using:kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $using:nodes.master.ipaddress )" "/opt/image-files/scripts/add-worker-to-master.sh -h $( $_.name ) -i $( $_.ipaddress )" | Out-Null
    ssh -i "$using:kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $_.ipaddress )" "/opt/image-files/scripts/configure-node.sh -h $( $_.name ) -i $( $_.ipaddress ) -t worker" 3> $null | Out-Null
    ssh -i "$using:kubePackerImageDirectoryPath\output-ssh\ssh.key" -o "StrictHostKeyChecking=no" "root@$( $_.ipaddress )" $using:clusterJoinCommand 3> $null | Out-Null
}

# it should be finished but wait for the nfs-host to be provisioned just in case
Wait-Job -Id $nfsHostDeployJob.Id | Out-Null

Pop-Location
