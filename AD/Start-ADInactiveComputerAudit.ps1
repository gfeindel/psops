<#
.SYNOPSIS
Identifies inactive computer accounts and e-mails the appropriate site support person.

.DESCRIPTION
Queries Active Directory for inactive computer accounts and sends e-mail audit reports
to the site support personnel.
#>

# This list must be updated whenever a new site is added to AD.
$SiteList = @{
    #<SiteCode> = "<email1>[,<email2>]"
}

function Get-InactiveComputers {
<#
.DESCRIPTION
Retrieves inactive computers for the given site.
.PARAMETER ADSite
The name of the OU under OU=Computers,...

.PARAMETER InactiveDays
The number of days since the last sign in after which a user is
considered inactive.
#>
    param(
        [parameter(Mandatory=$true)]
        [string]$ADSite,
        [int]$InactiveDays = 90,
        [string]$CC,
        [string]$From,
        [string]$SmtpServer
    )

    $ouPath = ""
    $cutoffDate = (Get-Date).AddDays(-$InactiveDays)
    $computers = Get-ADComputer -Filter * -SearchBase $ouPath -Properties LastLogonDate |
                    Where-Object {$_.LastLogonDate -lt $cutoffDate}
    
    $computers
}

function Format-InactiveComputerReport {
<#
.DESCRIPTION
    Converts an inactive computers list to nicely formatted HTML.
.PARAMETER data
    The data to be formatted in the report.
.PARAMETER Fields
    The list of field names to include in the tabular listing.
.PARAMETER Overview
    The summary statement to include before the table.
.PARAMETER Title
    The title of the report.
#>
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
    write-host ($data | Select-Object $Fields)
    $html = $data | Select-Object $Fields | ConvertTo-Html -Head $head -Body $body
    $html
}

$date = (Get-Date).ToShortDateString()

foreach($site in $SiteList.Keys) {

    $title = "$site Inactive Computers Report $date"
    $recipient = $SiteList[$site]

    Write-Host "Searching for inactive computers in $site."
    $computers = Get-InactiveComputers -ADSite $site | Sort-Object -Property $LastLogonDate
    $computerCount = ($computers | Measure-Object).Count
    
    if($computerCount -eq 0) {
        write-Host "No inactive computers in $Site."
        continue
    }

    $parms = @{
        Fields = @('Name','LastLogonDate','DistinguishedName')
        Title = $title
        Overview = "$computerCount $site computers have not connected for 90 days or more. Please disable them or delete them."
        Data = $computers
    }
    
    $report = Format-InactiveComputerReport @parms
    #$report | Out-File -FilePath "C:\FM\Reports\Inactive computers $Site.htm"

    Write-Host "$computerCount inactive computers found in $site."
    Write-Host "Sending report to $recipient"
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