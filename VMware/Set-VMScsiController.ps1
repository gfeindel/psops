<#
.Description
Changes a VM's SCSI controllers to the Paravirtual type by adding a new PVSCSI controller, then updating existing.
#>

param(
    [string]$VM
)

function Wait-VMState {
# Waits for the VM to enter the desired state, or timeout.
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$VM,
        [ValidateSet('PoweredOff','PoweredOn')]
        [string]$PowerState = 'PoweredOff',
        [ValidateScript({$_ -gt 0})]
        [int]$TimeoutSeconds = 10
    )
    $counter = $TimeoutSeconds
    do {
        Start-Sleep -Seconds 1
        $counter--
        $state = ($VM | Get-VM).PowerState
    } while($counter -ge 0 -and $state -ne $PowerState)
}

$objVM = Get-VM $VM

if($null -eq $objVM) {
    Write-Error "$VM not found."
}

$controllers = $objVM | Get-ScsiController
$hasPVSCSI = $false

foreach($controller in $controllers) {
    if($controller.Type -eq 'Paravirtual') {
        $hasPVSCSI = $true
    }
}

if(-not $hasPVSCSI) {
    Stop-VMGuest -VM $objVM -Confirm:$false
    # wait for it to shutdown
    
    $objVM | New-ScsiController -Type Paravirtual
    Start-VM -VM $objVM
    # wait for VM tools to start
    Stop-VMGuest -VM $objVM -Confirm:$false
    # wait for it to shutdown
    # Change existing controllers to PVSCSI
    $controllers |? {$_.Type -ne 'Paravirtual'} | Set-ScsiController -Type Paravirtual
    # To do: Remove the temporary PVSCSI controller
    Start-VM -VM $objVM
} else {
    # To do: Add code to update existing controllers that are not PVSCSI.
    Write-Host "$VM already has a PVSCSI controller."
}