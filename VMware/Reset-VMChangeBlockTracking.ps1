<#
    .SYNOPSIS
        Resets CBT for given VM

    .DESCRIPTION
        This script resets the change block  tracking (CBT) state on a VM without powering the VM off.
    
    .PARAMETER VMName
        The name of the virtual machine
    
    .EXAMPLE
        Reset-VMChangeBlockTracking -VMName myServer

    .AUTHOR
        Gabe.Feindel@freudenbergmedical.com

    .NOTES
        This code is adapted from a script provided by VMware in KB2139574. Apparently it works
        only on vmx-07 and newer VMs.

        v1.0 - Initial version of the script.
#>

[CmdletBinding()]
param(
[parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
[string[]]$VMName
)

begin {}

process {

    foreach($v in $VMName) {
        Write-Host "Reset CBT for $v"

        $vm = Get-VM $v
        if($vm -ne $null) {
            $spec = New-Object Vmware.Vim.VirtualMachineConfigSpec

            # Disable CBT
            $spec.ChangeTrackingEnabled = $false
            
            Write-Verbose "Disable CBT on $v"
            $vm.ExtensionData.ReconfigVM($spec)
            Write-Verbose "Snap/unsnap $v to reset CBT state."
            $snap = New-Snapshot -VM $vm -Name CBT-Reset
            Remove-Snapshot -Snapshot $snap -Confirm:$false
        
            # Enable CBT
            $spec.ChangeTrackingEnabled = $true
            Write-Verbose "Enable CBT on $v"
            $vm.ExtensionData.ReconfigVM($spec)
            Write-Verbose "Snap/unsnap $v to reset CBT state."
            $snap = New-Snapshot -VM $vm -Name CBT-Reset
            Remove-Snapshot -Snapshot $snap -Confirm:$false
        } else {
            Write-Host -ForegroundColor Red "$v not found."
        }
    }
}

end {}