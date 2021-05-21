[CmdletBinding()]
Param
(
    [string] $nfsHostIp,
    [string] $sshKeyFilePath,
    [string] $pvName
)

$sharePath = "/var/nfs/$pvName"

$output = ssh -i $sshKeyFilePath -o "StrictHostKeyChecking=no" "root@$( $nfsHostIp )" "/opt/image-files/scripts/new-nfs-share.sh -d $( $sharePath )"

if ($output -like "*directory already exists*") { throw "nfs share already exists at $sharePath" }

$pvYaml = @"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $pvName
spec:
  capacity:
    storage: 10Gi 
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: $nfsHostIp
    path: $sharePath
"@

$pvYaml | kubectl apply -f -