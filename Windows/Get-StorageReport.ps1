#Report free space on disks of all servers in the domain.
param(
[string]$DomainController,
[string]$SearchBase,
[PSCredential]$Credential
)
$servers = Get-ADComputer -ComputerName $DomainController -Filter "operatingSystem -like '*server*'" -SearchBase $SearchBase -Credential $Credential | select -ExpandProperty Name

$job = Invoke-Command -ComputerName $servers -ScriptBlock {Get-WmiObject Win32_LogicalDisk -Filter "driveType=3"} -AsJob
write-host "Waiting for task to complete..."
$job | Wait-Job

write-host "Job completed."
$results = Receive-Job

$results | Select PSComputerName,DeviceID,@{Name='SizeGB';Expression={[int]($_.Size/1GB)}},@{Name='FreeGB';Expression={[int]($_.FreeSpace/1GB)}}
