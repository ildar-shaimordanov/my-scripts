[CmdletBinding()]
param( [string]$hostname, [int]$port )

try {
	$tcpclient = New-Object System.Net.Sockets.tcpclient
	$tcpclient.Connect($hostname, $port)

	$tcpstream = $tcpclient.GetStream()

	$sslstream = New-Object System.Net.Security.SslStream($tcpstream, $false, { $true })

	$sslstream.AuthenticateAsClient('')
	$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]($sslstream.remotecertificate)

	$cert | Format-List | Out-String -Stream | Where-Object { $_ }
} catch {
	throw "Failure with $hostname`:$port`n $_"
} finally {
	#cleanup
	if ( $sslstream ) { $sslstream.close() }
	if ( $tcpclient ) { $tcpclient.close() }
}
