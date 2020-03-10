<#
.Description
Monitor response time for a URL endpoint and send email alerts when exceeds threshold.
#>
param(
    [string]$Uri,
    [int]$Interval = 10,
    [int]$AlertThreshold,
    [string]$AlertRecipient,
    [string]$SmtpServer
)

[Console]::TreatControlCAsInput = $true
Start-Sleep -Seconds 1
$Host.UI.RawUI.FlushInputBuffer()

while($true) {
    $timeTaken = Measure-Command -Expression {Invoke-WebRequest -Uri $Uri}
    $o = [pscustomobject]@{
        Uri = $Uri
        CheckTime = Get-Date
        AlertThreshold = $AlertThreshold
        ResponseTime = [int]($timeTaken.TotalMilliseconds)
    }

    Write-Output $o 
    
    if($timeTaken.TotalMilliseconds -ge $AlertThreshold) {
        $parms = @{
            From = 'Monitor <noreply@nhec.com>'
            To = $AlertRecipient
            Subject = "Monitor Alert: $Uri Response $($timeTaken.TotalMilliseconds) ms"
            Body = ($o | Format-List | Out-String)
            SmtpServer = $SmtpServer
        }
        Write-Warning "Response time $($timeTaken.TotalMilliseconds) ms exceeds $AlertThreshold ms"
        Send-MailMessage @parms
    }

    
    # Check for CTRL+C
    if($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        if([Int]$Key.Character -eq 3) {
            break;
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }
    Start-Sleep -Seconds $Interval
}

Write-Host "Done."

[Console]::TreatControlCAsInput = $false
