
function Remove-CiscoAmp() {
[CmdletBinding()]
param([string]$Password)

    # If Cisco Amp is installed, remove it.
    [string]$regkey = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Immunet Protect'
    [string]$uninstallString = ''
    [string]$parms = @('/S',"/password $Password")

    if( Test-Path $regkey) {
        $uninstallString = (Get-ItemProperty -Path $regKey -Name UninstallString).UninstallString
        if(-not $uninstallString) {
            Write-Error "Uninstall string not specified."
            return 1
        } else {
            Write-Verbose "Running $uninstallString $parms"
            Start-Process -Wait -FilePath $uninstallString -ArgumentList $parms
        }
    } else {
        Write-Error "Immunet Protect registry key not found: $regkey"
        return 2
    }
}

Remove-CiscoAmp -Verbose