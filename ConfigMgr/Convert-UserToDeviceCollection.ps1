<#
    .DESCRIPTION
    Add to a device collection the primary devices for all users in a user collection.
#>
function Convert-UserToDeviceCollection {
    [CmdletBinding()]
	param(
		[string]$UserCollectionName,
		[string]$DeviceCollectionName
	)
	
	$users = Get-CMUser -CollectionName $UserCollectionName
    $deviceIds = @()
    
    # Get the primary devices for all users in the collection
	foreach($user in $users) {
        $devices = @()
        $devices = @(Get-CMUserDeviceAffinity -UserId $user.ResourceId)
        if($devices) {
            Write-Verbose "Adding device $($devices[0].ResourceName) ($($devices[0].ResourceId)) to list"
            $deviceIds += $devices[0].ResourceId # Should we include all devices, or only the first one?
        } else {
            Write-Warning "No devices found for $($user.Name)"
        }
	}
	
    $ruleIds = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $DeviceCollectionName | 
			Select-Object -ExpandProperty ResourceId
	
	# Remove devices no longer in scope
	foreach($ruleId in $ruleIds) {
		if($ruleId -notin $deviceIds) {
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $DeviceCollectionName -ResourceId $ruleId
            Write-Verbose "Removed collection direct membership rule for resource $ruleId."
        }
	}
	
	# Add direct membership rules for new devices
	Foreach($deviceId in $deviceIds) {
		if($deviceId -notin $ruleIds) {
            Add-CMDeviceCollectionDirectMembershipRule -CollectionName $DeviceCollectionName -ResourceId $deviceId -EA SilentlyContinue
            Write-Verbose "Added collection direct membership rule for device $deviceId"
		} else {
            Write-Verbose "Device $deviceId already a member of the collection."
        }
	}
}