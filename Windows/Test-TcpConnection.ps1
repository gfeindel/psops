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

[Console]::TreatControlCAsInput = $true
Start-Sleep -Seconds 1
$Host.UI.RawUI.FlushInputBuffer()

[int]$total = 0
[int]$success = 0
[datetime]$startTime = Get-Date

while($true) {
    $total++
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect($Destination,$Port)
        if($tcp.Connected) {
            Write-Log "Successfully connected to ${Destination}:${Port}"
            $tcp.Close()
            $success++
        } else {
            Write-Log "Not connected."
        }
    } catch {
        Write-Log "Failed to connect to $Destination"
    } finally {
        $tcp.Dispose()
    }
    # Check for CTRL+C
    if($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        if([Int]$Key.Character -eq 3) {
            break;
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }
    Start-Sleep -Milliseconds $Timeout
}
$successRate = [int]($success/$total*100)
$duration = [datetime]::Now - $startTime
Write-Host "$successRate% success, $(100-$successRate)% failed. Duration: $duration"
