<#
.DESCRIPTION
Get inactive users in Active Directory

#>

param(
[int]$InactiveDays=90,
[string]$OUPath
)

$cutoffDate = (get-date).AddDays(-$InactiveDays)

$Parms = @{
    'SearchBase' = $OUPath
    'Properties' = 'Description','LastLogonDate','PasswordLastSet','Enabled'
    'Filter' = '*'
}

Get-ADUser @Parms |? { $_.LastLogonDate -lt $cutoffDate }

