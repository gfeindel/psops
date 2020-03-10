<#
.DESCRIPTION
Test for existence of Sality.AU malware.
.NOTES
https://www.microsoft.com/security/portal/threat/encyclopedia/Entry.aspx?Name=Worm:Win32/Sality.AU&ocid=-2147330638
#>

$checkMutex = $false
$checkRegistry = $false

$MalwareName = "Win32/Sality.AU"

try { 

    $mutex = [System.Threading.Mutex]::OpenExisting('woemnm593jfe');
    if($mutex) {
        $checkMutex = $true
    }
} catch {
    $checkMutex = $false
}

$subkeys = Get-ChildItem "Registry::HKEY_USERS\" -ErrorAction SilentlyContinue
foreach($sk in $subkeys) {
    $key = Get-Item "Registry::$($sk.Name)\Software\zrfke" -ErrorAction SilentlyContinue
    if($key) {
        $checkRegistry = $true
    }
}

# Report infected if either condition is true.
if($checkMutex -or $checkRegistry) {
    write-host "The system is infected with $MalwareName" -ForegroundColor Red
    return $true
} else {
    write-host "The system is clean." -ForegroundColor Green
    return $false
}
