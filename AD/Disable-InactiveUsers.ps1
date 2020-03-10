# Users not logged in for 60 days: Send email notice to user/manager/owner?
# Users not logged in for 90 days: Disable

Import-Module ActiveDirectory

$now = get-Date
$cutoffDate1 = (get-date).AddDays(-60)
$cutoffDate2 = (get-date).AddDays(-90)

$ouPath = ""

$users = Get-ADUser -Filter * -Searchbase $ouPath -Properties LastLogonDate,WhenCreated,Description

"The following users will be disabled in 30 days:"

# Get users that haven't logged in for more than 60 days, less than 90 days,
# Or who have never logged in, but whose account was created in the same time frame.
$users |? {
        ($_.LastLogonDate -gt $cutoffDate2 -and $_.LastLogonDate -lt $cutoffDate1) -or
        ($_.LastLogonDate -eq $null -and $_.WhenCreated -gt $cutoffDate2 -and $_.WhenCreated -lt $cutoffDate1) -and
        $_.Enabled} `
       | Select Name,SamAccountName,WhenCreated,LastLogonDate,@{Name='LastLogonDays';Expression={[int]($now-$_.LastLogonDate).TotalDays}},Description |ft

"The following users have been disabled:"

# Get users that haven't logged in for more than 90 days
# Or who have never logged in, but whose account was created more than 90 days ago.
$users |? {
        ($_.LastLogonDate -and $_.LastLogonDate -le $cutoffDate2) -or
        ($_.LastLogonDate -eq $null -and $_.WhenCreated -lt $cutoffDate2) -and
        $_.Enabled} `
       | Select Name,SamAccountName,WhenCreated,LastLogonDate,@{Name='LastLogonDays';Expression={[int]($now-$_.LastLogonDate).TotalDays}},Description |ft

