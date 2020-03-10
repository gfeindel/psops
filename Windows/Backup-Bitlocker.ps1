<#
.DESCRIPTION
Backup the Bitlocker recovery password to AD. If ADMT was used to migrate a PC, the TPM owner hash is migrated automatically, but the recovery password is not.
#>
[CmdletBinding()]
param([switch]$RunOnce)

# Does not use the Bitlocker module, so that it will run on Windows 7 and PS < 2.0

$volume = Get-WmiObject -Namespace Root\CIMV2\Security\MicrosoftVolumeEncryption -ClassName Win32_EncryptableVolume -Filter "DriveLetter='C:'"

if(-not $volume) {
    Write-Verbose "No encryptable volumes found."
    return
}

$protector = $volume.GetKeyProtectors()
foreach($p in $protector.VolumeKeyProtectorID) {
    $type = $volume.GetKeyProtectorType($p)
    # Recovery Password = 3
    if($type.KeyProtectorType -eq 3) { 
        Write-Verbose "Found key protector $p"
        $result = $v.BackupRecoveryInformationToActiveDirectory($p)
        if($result.ReturnValue -eq 0) {
            Write-Verbose "Successfully backed up key protector to Active Directory"
        } else {
            Write-Error "Failed to backup key protector to AD: $($result.ReturnValue)"
        }
    }
}