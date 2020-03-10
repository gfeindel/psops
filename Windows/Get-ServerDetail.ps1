function Get-ServerDetail {
param([string]$ComputerName)

    $os = gwmi -ComputerName $ComputerName Win32_OperatingSystem
    $cs = gwmi -ComputerName $ComputerName Win32_ComputerSystem

    # Get info about data on the server
    $volumes = gwmi -ComputerName $ComputerName WIn32_LogicalDisk -Filter 'DriveType=3'

    # Get share info
    $shares = gwmi -ComputerName $ComputerName Win32_Share

    # Get app info
    
    # Get service info
    $services = Get-Service -ComputerName $ComputerName

    # Get current connection info
    $connections = invoke-command -ComputerName $ComputerName {'cmd /c netstat -na | find "ESTABLISHED"'}
    
    # Get access info

}