param(
    [parameter(Mandatory)]
    [string]$Destination,
    [parameter(Mandatory)]
    [int]$Port,
    [int]$Timeout=1000,
    [string]$LogFile
)

function Write-Log {
    param([string]$msg)

    $d = Get-Date
    $strTime = $d.ToString()
    Write-Host $msg
    "$strTime $msg" | Out-File -FilePath $LogFile -Append -Encoding Utf8
}



while($true) {
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect($Destination,$Port)
        if($tcp.Connected) {
            Write-Log "Successfully connected to ${Destination}:${Port}"
            $tcp.Close()
        } else {
            Write-Log "Not connected."
        }
    } catch {
        Write-Log "Failed to connect to $Destination"
    } finally {
        $tcp.Dispose()
    }
    Start-Sleep -Milliseconds $Timeout
}


