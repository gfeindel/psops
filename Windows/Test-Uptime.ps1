function Test-Uptime {
    <#
    .SYNOPSIS
    Checks the uptime for a computer against a desired value.
    
    .DESCRIPTION
    Checks the last boot time of a computer and compares to a specified date.

    .PARAMETER ComputerName
    The name or names of computers to test.

    .PARAMETER Days
    The maximum days of uptime to pass the test.
    
    .EXAMPLE
    Test-Uptime -ComputerName JFVDC1 -Days 30
    
    .NOTES
    
    #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline=$true)]
        [string[]]$ComputerName='localhost',
        [ValidateRange(1,365)]
        [int]$Days = 30,
        [System.Management.Automation.PSCredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        $cutoffDate = (get-date).AddDays(-$Days)
    }
    process {
        foreach($cs in $ComputerName) {
            if(-not (Test-Connection $cs -Count 2 -EA SilentlyContinue)) {
                write-error "$cs is unreachable."
                continue
            }
            try {
                $os = $null
                if($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
                    $os = Get-WmiObject -ComputerName $cs Win32_OperatingSystem
                } else {
                    $os = Get-WmiObject -ComputerName $cs Win32_OperatingSystem -Credential $Credential
                }
                $lastBootupTime = $os.ConvertToDateTime($os.LastBootupTime)
                [pscustomobject]@{
                    ComputerName = $cs
                    UptimeStatus = ($lastBootupTime -ge $cutoffDate)
                    LastBootupTime = $lastBootupTime
                }
                
            } catch {
                Write-Error $_
            }
        }
    }
}