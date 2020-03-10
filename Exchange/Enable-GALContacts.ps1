[CmdletBinding()]
param()
<#
    .SYNOPSIS
    Enable contacts in the Global Address List OU

    .DESCRIPTION
    F&Co synchronizes contact objects among participating Freudenberg AD forests.
    These contact objects must be mail-enabled to appear in the OAB. Must be run with appropriate permissinos.
#>

$ExchangeServer = ""
$ConnectionUri = "http://$ExchangeServer/Powershell"

# Connect to EMC using current credentials.
try {
    Write-Verbose "Connecting to EMS at $ConnectionUri"
    $ses = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos
    Import-PsSession $ses
} catch {
    Write-Error "Failed to connect to EMS on $ExchangeServer. Exiting."
    exit
}

[string]$ouPath = ''
[int]$contactCount = 0
[int]$errorCount = 0

Write-Verbose "Enabling all contacts in $ouPath"
Get-Contact -OrganizationalUnit $ouPath -ResultSize Unlimited -RecipientTypeDetails Contact |Foreach-Object {
    $recipient = "$($_.DistinguishedName) ($($_.WindowsEmailAddress))"
    try {
        Enable-MailContact -Identity $_.DistinguishedName -ExternalEmailAddress $_.WindowsEmailAddress | Out-Null
        Write-Verbose "Enable $recipient : Success"
        $contactCount++
    } catch {
        Write-Warning "Enable $recipient : Failed. "
        $errorCount++
    }
}

Write-Verbose "Enabled $contactCount contacts. Check the log for warnings, which I can't detect."
Write-Verbose "Failed to enable $errorCount contacts."

Remove-PSSession $ses
