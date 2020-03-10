# Script created by Maurice Daly - Provided as is, as always verify code before using # 

# Credentials should be necessary if using the "run as" option in the TS.
#$Username = 'yourdomain\useraccount' 
#$encrypted = Get-Content -Path '\\fileserver\yourshare\Required.txt' 
#$key = (1..16) 
#$Password = $encrypted | ConvertTo-SecureString -Key $key 
#$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password 

# Need to locate local DC
$DC = "" 

$ADPowerShell = New-PSSession -ComputerName $DC -Credential fmedical\adm_feindel

#$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment

$CurrentName = $env:COMPUTERNAME 
#$SiteCode = $tsenv.Value("OSDLocation")
#$ChassisType = $tsenv.Value("OSDChassisType")
#$DomainOUName = $tsenv.Value("OSDDomainOUName")
$DomainOUName = ""

$SiteCode = ""
$ChassisType = "D"
$prefix = "$SiteCode$ChassisType"

netsh advfirewall set allprofiles state off 

# Requires a 2012 R2 DC, or 2008 R2 with the AD module installed.
$ComputerName = Invoke-Command -Session $ADPowerShell -scriptblock { 
param(
[string]$prefix,
[string]$DomainOUPath
)
    import-module ActiveDirectory 

    #$Username = 'yourdomain\useraccount' 
    #$encrypted = Get-Content -Path '\\fileserver\yourshare\Required.txt' 
    #$key = (1..16) 
    #$password = $encrypted | ConvertTo-SecureString -Key $key 
    #$DomainCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password 

    $UsedNumbers = Get-ADComputer -Filter * -Properties Name | Where-Object { $_.Name -like ("${prefix}*") } | ForEach-Object { Write-Output $($_.Name.Substring($_.Name.Length-4)) } 
    $NextNumber = 1000
    $adcheck = 0 
   # Do 
   # { 
        # Increment active directory check flag 
     #   $adcheck++ 
    $sNum = ""

    Do 
    { 
        $NextNumber++ 
        $sNum = "{0:0000}" -f $NextNumber
    } 
    Until ($UsedNumbers.Contains($sNum) -eq $false) 

    $ComputerName = ("$prefix$sNum") 

    #    start-sleep -Seconds 2 
    #} 
    #while ($adcheck -le 3) 

    #Rename-Computer -ComputerName $CurrentComputerName -NewName $ComputerName -DomainCredential $DomainCredentials
    # Stage the computer account so it can't be taken by concurrent oSD sessions.
    New-ADComputer -Name $ComputerName -Path $DomainOUPath | Out-null
    write-host "Staged computer $ComputerName in $DomainOUPath"

    return $ComputerName
} -ArgumentList $prefix,$DomainOUName

Remove-PSSession $ADPowerShell 

$ComputerName

# Allow the TS to do the rename as usual.
#Rename-Computer -NewName $ComputerName -Force
#$tsenv.Value("OSDComputerName") = $ComputerName

# Re-enable the local firewall 
netsh advfirewall set allprofiles state on 