# The Bartender Print Scheduler service sometimes fails to start
# on system startup, or it stops responding during normal operations.
# This script checks for TCP/5150 and service status. It restarts
# the service if either check fails.

[CmdletBinding()]
param()

$svcName = "Bartender Print Scheduler"
$portNum = 5150
$status = $true

$svc = Get-Service $svcName
$client = New-Object Net.Sockets.TcpClient
$client.Connect("localhost",$portNum)

if($svc.Status -eq 'Running') {
	write-verbose "$svcName is running"
} else {
	Write-Error "$svcName is not running. Will try to start."
	Start-Service $svcName
}

if($client.Connected) {
	Write-Verbose "localhost:$portNum is listening."
	$client.Close()
} else {
	$status = $false
	Write-Error "Failed to connect to TCP/$portNum. Restarting $svcName"
	Restart-Service $svcName -Force
}

$client.Dispose()
