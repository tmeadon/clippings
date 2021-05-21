$hostname = 'www.google.com'
$certNamePrefix = ''

$req = [System.Net.Sockets.TcpClient]::new($hostname, '443')
$stream = [System.Net.Security.SslStream]::new($req.GetStream())
$stream.AuthenticateAsClient($hostname)
$cert = $stream.RemoteCertificate

$chain = [System.Security.Cryptography.X509Certificates.X509Chain]::new()
$chain.Build($cert)

for ($i = 0; $i -lt $chain.ChainElements.Count; $i++)
{
    Set-Content -Path "$certNamePrefix-$i.cer" -Value $chain.ChainElements[$i].Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert) -AsByteStream
}