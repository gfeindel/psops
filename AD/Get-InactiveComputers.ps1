# http://www.lazywinadmin.com/2014/03/powershell-find-inactive-computers-in.html
# Uses ADSISearcher for compatibility with older versions of Windows Server that
#  don't have the ActiveDirectory PS module.
param(
[string]$ServerName,
[string]$SearchRoot,
$MaxDays = 90
)

$cutoffDate = (Get-Date).AddDays(-$MaxDays)

$searcher = [adsisearcher]""
$searcher.searchRoot = [adsi]"LDAP://$ServerName/$SearchRoot"
$searcher.SizeLimit = "1000"
$searcher.Filter = "(objectCategory=computer)"
$searcher.PropertiesToLoad.AddRange(('name','samaccountname','distinguishedname','operatingsystem','description','lastlogontimestamp'))
Foreach ($ComputerAccount in $searcher.FindAll()){
    $o = New-Object -TypeName PSObject -Property @{
        Name = $ComputerAccount.properties.name -as [string]
        SamAccountName = $ComputerAccount.properties.samaccountname -as [string]
        DistinguishedName = $ComputerAccount.properties.distinguishedname -as [string]
        OperatingSystem = $ComputerAccount.properties.operatingsystem -as [string]
        Description = $ComputerAccount.properties.description -as [string]
        LastLogonTimestamp = [datetime]::FromFileTime(0)
    }
    if($ComputerAccount.Properties.lastlogontimestamp) {
        $o.LastLogonTimestamp = [datetime]::FromFileTime($ComputerAccount.Properties.lastlogontimestamp.Item(0))
    }
    if($o.LastLogonTimestamp -lt $cutoffDate) { $o }
}