#Veeam offsite backups statistics


$date = (Get-Date).AddDays(-90)

$j = Get-VbrJob -Name "*to*"
#Change filter to switch from offsite to site specific jobs

$guids = $j.Id.Guid

#stole this from https://gist.github.com/smasterson/9136468 as I had no idea how to convert the duration format into something readable. Would have liked hours only better though.
function Get-Duration {
  param ($ts)
  $days = ""
  If ($ts.Days -gt 0) {
    $days = "{0}:" -f $ts.Days
  }
  "{0}{1}:{2,2:D2}:{3,2:D2}" -f $days,$ts.Hours,$ts.Minutes,$ts.Seconds
}

#filters only successful backups with more than 0 bytes transfered
get-vbrbackupsession | where-object {$_.JobId -in $guids -and $_.endtimeutc -gt $date -and $_.Result -eq "Success" -and $_.Info.Progress.TransferedSize -ne '0'} | sort-object JobName -Descending | select JobName, CreationTime, @{Name="Duration [D:HH:MM:SS]";Expression={Get-Duration -ts $_.Info.Progress.Duration}}, @{Name="BackupSize[GB]";Expression={[math]::round(($_.Info.Progress.TransferedSize / 1073741824), 2)}} | export-csv c:\temp\offsite.csv


