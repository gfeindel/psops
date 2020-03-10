function Get-LogonHistory {
    <#
    .SYNOPSIS
    Query the security log for logon event 4624
    
    .DESCRIPTION
    Queries the security log on given computers for logon events in the last 24 hours.
    
    .PARAMETER ComputerName
    The computer(s) whose security logs to query.

    .PARAMETER Credential
    Credentials to use when connecting to the computer(s).

    .PARAMETER StartTime
    Retrieve logon events that occurred after StartTime. Defaults to Now-24 hours.

    .PARAMETER EndTime
    Retrieve logon events that occurred before EndTime. Defaults to Now.
    
    .EXAMPLE
    Get-LogonHistory -ComputerName CARL1206
    #>
    param(
        [string[]]$ComputerName='localhost',
        [System.Management.Automation.PSCredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [DateTime]
        $StartTime  = (Get-Date).AddDays(-1),
        [DateTime]
        $EndTime    = [DateTime]::Now
    )
    process {
        foreach($name in $ComputerName) {
            if( -not (Test-Connection -Count 1 -ComputerName $name -Quiet) ) {
                write-error "$name is offline"
                continue
            }

            try {
                $parms = @{
                    LogName = 'Security'
                    ID = '4624'
                    StartTime = $StartTime
                    EndTime =   $EndTime
                }
                if($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
                    $events = Get-WinEvent -ComputerName $name -FilterHashtable $parms
                } else {
                    $events = Get-WinEvent -ComputerName $name -FilterHashtable $parms -Credential $Credential
                }

                $events |Foreach-Object {
                    [pscustomobject]@{
                        ComputerName = $name
                        LogonTime = $_.TimeCreated
                        UserName = $_.Properties[5].Value
                    }
                }
            } catch {
                Write-Error "Unable to query security log on $name"
            }
        }
    }
}