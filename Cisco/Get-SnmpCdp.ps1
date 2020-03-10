<#
.Description
Obtains the CDP neighbors and interfaces for a specified Cisco device
#>

param(
    [string]$address,
    [string]$community
)

$oidCdpDeviceId = '.1.3.6.1.4.1.9.9.23.1.2.1.1.6'
$oidCdpDevicePort = '.1.3.6.1.4.1.9.9.23.1.2.1.1.7'
$oidCdpDeviceAddr = '.1.3.6.1.4.1.9.9.23.1.2.1.1.4'

$snmp = New-Object -ComObject Oleprn.OleSnmp

try {
    $snmp.Open($address,$community,2,1000)
    $snmp.GetTree($oidCdpDeviceId)
    $snmp.GetTree($oidCdpDevicePort)
    #$snmp.GetTree($oidCdpDeviceAddr) # Returns binary data.
    $snmp.Close()
} catch {
    $snmp.Dispose()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($snmp)
}

