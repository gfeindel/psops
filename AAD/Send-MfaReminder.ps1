<#
.Description
Queries for users that have not configured MFA, or have not configured correctly. Sends
email reminder to them.
#>

param(
    [string]$To,
    [string]$From,
    [string]$SmtpServer
)
# Connect to MSOl
Connect-MsolService

# Query list of users
$users = Get-MsolUser -All

$unRegistered = @()
$nonApp = @()

# Filter only users in scope. (Active users to whom the controls will apply)
# Other than licensed, what other criteria?
$users |Where-Object {$_.IsLicensed} |ForEach-Object {

# Query users who haven't configured MFA or don't use notifications
if('' -eq $_.StrongAuthenticationMethods -or $_.StrongAuthenticationMethods.Count -lt 2) {
    $unRegistered += @($_)
}

if('' -ne $_.StrongAUthenticationMethods) {
    $defaultMfa = $_.StrongAuthenticationMethods |Where-Object {$_.IsDefault}
    if($defaultMfa.MethodType -ne 'PhoneAppNotification') {
        $nonApp += @($_)
    }
}
}

# Send emails based on user scenario

$header = @"
<html>
<head>
<style type="text/css">
body, p, td, th, h1, h2, h3, h4 {
    font-family: arial, sans serif;
}
p, td, th {
    font-size: medium
}
</style>
</head>
"@

$table1 = $unRegistered | Sort-object City,Office,Department,DisplayName | ConvertTo-Html -Property DisplayName,Department,Office,City -Fragment
$table2 = $nonApp | Sort-Object City,Office,Department,DisplayName | ConvertTo-Html -Property DisplayName,Department,Office,City -Fragment

$body = @"
$header
<p>$($unRegistered.Count) users have not registered for MFA. $($nonapp.Count) users do not use app notifications. 
Please help unregistered users to register their accounts for two-step verification. Consider encouraging the others 
to switch their default method to app notifications.</p>
<p>If you believe an account should be excluded from the multifactor authentication requirement, <b>please inform the server team immediately</b>.</p>
<h3>Unregistered users</h3>
$table1
<h3>Non-app notification users</h3>
$table2
</html>
"@

$dateString = [dateTime]::Now.ToShortDateString()

$parms = @{
    To = $To
    From = $From
    Subject = "MFA Report ${dateString}: $($unRegistered.Count) unregistered; $($nonapp.Count) not using the app"
    BodyAsHtml = $true
    Body = $body
    SmtpServer = $SmtpServer
}

Send-MailMessage @parms
# Query users who haven't chosen the app notification as default.
# Notify them -- How avoid pestering users that legitimately don't want to use this?
