<#
.Description
A thin wrapper around the ping command that adds timestamp data to the response data.
Useful to log ping data to diagnose difficult network issues.
#>

param(
    $Destination,
    $LogFile="$env:temp\monitor-latency.log",
    $Timeout=1000
)

[Console]::TreatControlCAsInput = $true
Start-Sleep -Seconds 1
$Host.UI.RawUI.FlushInputBuffer()

@"
Ping $Destination and save results to $LogFile
Timestamp Destination Latency (ms)
"@ | Set-Content $LogFile

while($true) {

    $d = Get-Date

    try {
        $p = Test-Connection $Destination -Count 1 -ErrorAction Stop
        $p
        "$($d) $($p.IPv4Address) $($p.ResponseTime)" | Add-Content $LogFile
    } catch {
        Write-Host "$d $Destination unreachable."
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

Write-Host "Results saved to $LogFile."