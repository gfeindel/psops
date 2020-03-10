<#
.DESCRIPTION
Send Wake-on-LAN packet to specified MAC address(es)
.PARAMETER MACAddress
  The MAC address(es) to send magic packets to.
#>
function Send-WOL {
    param (
        [parameter(
            mandatory=$true,
            position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateLength(17,17)]
        [ValidatePattern("^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$")]
        [string[]]$MACAddress
    )
    foreach ($MAC in $MACAddress) {
        try {
            $MAC = $mac.split(':') | %{ [byte]('0x' + $_) }
            $UDPclient = new-Object System.Net.Sockets.UdpClient
            $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
            $Packet = [byte[]](,0xFF * 6)
            $Packet += $MAC * 16
            Write-Verbose ([bitconverter]::tostring($Packet))
            [void] $UDPclient.Send($Packet, $Packet.Length)
            Write-Output "WOL command sent to $MAC"
        } catch [system.exception] {
            Write-Output "ERROR: Unable to send WOL command to $MAC"
        }
    }
}