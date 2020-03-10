<#
.DESCRIPTION
Get Server Disk Report
#>

param(
[parameter(ValueFromPipeline=$true)]
[string[]]$ComputerName='localhost'
)

process {

function Get-DiskStatus {
param($ComputerName)

    $disks = Get-WmiObject -ComputerName $ComputerName Win32_LogicalDisk -Filter "DriveType=3"
    foreach($disk in $disks) {
        [pscustomobject]@{
            ComputerName=$ComputerName;
            DriveName=$disk.DeviceID;
            DriveSizeGB=[int]($disk.Size/1GB);
            DriveFreeSpaceGB=[int]($disk.FreeSpace/1GB);
            DriveFreePct=[int](100*$disk.FreeSpace/$disk.Size);
        }
    }
}

foreach($computer in $ComputerName) {
    if((Test-Connection $computer -Count 2)) {
        Get-DiskStatus $computer
    } else {
        write-error "$computer is unreachable."
    }
}

}