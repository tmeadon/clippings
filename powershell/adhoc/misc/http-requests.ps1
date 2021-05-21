# call http host using different values for server name and host header (e.g. to hit a host behind a load balancer directly)

$realServer = ''
$virtualHost = ''
$httpDirectory = ''

# using Invoke-WebRequest
Invoke-WebRequest -Uri "https://$realServer/$httpDirectory" -Headers @{"host"=$virtualHost} -UseBasicParsing

# using curl
curl --include --resolve ($virtualHost + ':' + $realServer) "https://$virtualHost/$httpDirectory"
