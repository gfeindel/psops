<#
.Description
Parses events from the Microsoft/Windows/WMI-Activity/Trace log for analysis.
#>
[CmdletBinding(DefaultParameterSetName = 'Path')]
param(
    # Retrieve events from a saved EVTX log
    [parameter(Mandatory,ParameterSetName="Path")]
    [string]$FilePath,
    # Retrieve events from the live trace log.
    [parameter(Mandatory,ParameterSetName="Live")]
    [switch]$Live,
    [int]$MaxEvents=0
)

# event properties:
# 0 - Correlation Id
# 1 - Group Operation Id
# 2 - Operation ID
# 3 - Operation
# 4 - Client Machine
# 5 - Client Machine FQDN?
# 6 - User
# 7 - Client Process Id
# 8 - Namespace Name (numeric)
# 9 - Namespace name (text)

# Hash table remembers previously looked up processes.
$processes = @{}
$events = 0

$parms = @{
    Oldest=$true
    # Event ID 11 are the most interesting trace events, signifying specific queries.
    FilterXPath = "*[System[(EventID=11)]]"
}
if($Path) {
    $parms['Path'] = $FilePath
} else {
    $parms['LogName'] = 'Microsoft-Windows-WMI-Activity/Trace'
}
if($MaxEvents) {
    $parms['MaxEvents'] = $MaxEvents
}

Write-Host "Retrieve events from $FilePath"
Get-WinEvent @parms  |
Foreach-Object {
    $ProcessId = [int]($_.Properties[7].Value)
    $o = [pscustomobject]@{
        EventId = $_.Id
        ClientProcessId = $ProcessId
        ClientProcessName = ""
        Timestamp = $_.TimeCreated
        Operation = $_.Properties[3].Value
        User = $_.Properties[6].Value
        Namespace = $_.Properties[9].Value
    }

    if(-not $processes.Contains($ProcessId)) {
        $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if($null -ne $Process) {
            $processes[$ProcessId] = $Process.ProcessName
        } else {
            $processes[$ProcessId] = "unknown"
        }
    }
    $o.ClientProcessName = $processes[$ProcessId]
    $o
}