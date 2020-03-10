<#
.SYNOPSIS
Identifies inactive user accounts and e-mails the appropriate site support person.

.DESCRIPTION
Queries Active Directory for inactive user accounts and sends e-mail audit reports
to the site support personnel.
#>
[CmdletBinding()]
param()

$SiteList = @{
    #<SiteCode> = "<email1>[,<email2>]"
}

function Get-InactiveUsers {
    <#
    .DESCRIPTION
    Retrieves inactive users for the given site.
    .PARAMETER ADSite
    The name of the OU under OU=Users,OU=FMEDICAL,DC=FMEDICAL,DC=NET

    .PARAMETER InactiveDays
    The number of days since the last sign in after which a user is
    considered inactive.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$ADSite,
        [int]$InactiveDays = 90,
        [string]$CC,
        [string]$From,
        [string]$SmtpServer
    )

    $ouPath = ""
    $timespan = New-TimeSpan -Days $InactiveDays
    $users = Search-ADAccount -AccountInactive -TimeSpan $timespan -SearchBase $ouPath
    
    $users
}

function Format-InactiveUserReport {
    <#
    .DESCRIPTION
        Converts an inactive users list to nicely formatted HTML.
    .PARAMETER data
        The data to be formatted in the report.
    .PARAMETER Fields
        The list of field names to include in the tabular listing.
    .PARAMETER Overview
        The summary statement to include before the table.
    .PARAMETER Title
        The title of the report.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [psobject[]]$data,
        [parameter(Mandatory=$true)]
        [string[]]$Fields,
        [parameter(Mandatory=$true)]
        [string]$Overview,
        [parameter(Mandatory=$true)]
        [string]$Title
    )

    $head = @"
<style type='text/css'>
BODY {
    font-family: Arial, sans serif;
    font-size: 11pt;
}
TABLE {
    border-width: 1px;
    border-style: solid;
    border-color: #AAA;
    border-collapse: collapse;
}
TH {
    background-color: #009;
    color: white;
}
TH, TD {
    padding: 0px;
    border-width: 1px;
    border-style: solid;
    border-color: #AAA;
}

</style>
"@

    $body = "<h2>$Title</h2>"
    $body += "<p>$Overview</p>"
    Write-Verbose ($data | Select-Objet $Fields)
    $html = $data | Select-Object $Fields | ConvertTo-Html -Head $head -Body $body
    $html
}

$date = (Get-Date).ToShortDateString()

foreach($site in $SiteList.Keys) {

    $title = "$site Inactive Users Report $date"
    $recipient = $SiteList[$site]

    Write-Verbose "Searching for inactive users in $site."
    $users = Get-InactiveUsers -ADSite $site | Sort-Object -Property $LastLogonDate
    $usercount = ($users | Measure-Object).Count
    
    if($usercount -eq 0) {
        Write-Verbose "No inactive users in $Site."
        continue
    }

    $parms = @{
        Fields = @('Name','LastLogonDate','DistinguishedName')
        Title = $title
        Overview = "$usercount $site users have not signed in for 90 days or more. Please disable them or delete them."
        Data = $users
    }
    
    $report = Format-InactiveUserReport @parms
    #$report | Out-File -FilePath "C:\FM\Reports\Inactive Users $Site.htm"

    Write-Verbose "$usercount inactive users found in $site."
    Write-Verbose "Sending report to $recipient"
    $parms = @{
        Body = [string]::join("",$report)
        BodyAsHtml = $true
        To = $recipient
        CC = $CC
        From = $From
        Subject = $title
        SmtpServer = $SmtpServer
    }
    Send-MailMessage @parms

}