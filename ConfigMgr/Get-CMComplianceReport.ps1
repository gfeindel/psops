function Get-SoftwareUpdateComlianceReport {
	<#
	.SYNOPSIS
	Runs the Compliance 7 software updates report.
	
	.DESCRIPTION
	Runs the report, Compliance 7 - Computers in a specific compliance state for an update group (secondary) and
	returns the results of the report.
	
	.PARAMETER SrsServer
	The name of the SQL Reporting Services instance.
	
	.PARAMETER SiteCode
	The Configuration Manager Site Code.
	
	.PARAMETER CollectionID
	The collection to scope this report.

	.PARAMETER SoftwareUpdateGroupName
	The name of the software upgrade group. Use * for partial match.
	
	.PARAMETER StateName
	The compliance state to retrieve. If not specified, returns all compliance states (Compliant, Non-compliant, Unknown)

	.EXAMPLE
	Get-CMComplianceReport -StateName 'Non-compliant'
	
	.NOTES
	General notes
	#>
	param(
		[parameter(Mandatory)]
		[ValidatePattern("[a-zA-Z0-9_\-]+")]
		[string]$SrsServer,

		[parameter(Mandatory)]
		[string]$SiteCode,

		[parameter(Mandatory)]
		[string]$CollectionID,

		[parameter(Mandatory,ValueFromPipeline)]
		[string]$SoftwareUpdateGroupName, #should perform input validation here.

		[ValidateSet('Compliant','Non-compliant','Compliance state unknown')]
		[string[]]$StateName=@('Compliant','Non-compliant','Compliance state unknown'),

		[ValidateNotNull()]
		[System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
	)

	begin {
		$ReportPath='Software Updates - A Compliance/Compliance 7 - Computers in a specific compliance state for an update group (secondary)'
		$Format='XML'
		$ReportPathEncoded=[uri]::EscapeDataString($ReportPath)

		$webClient = New-Object System.Net.WebClient
	
		# Use current credentials unless provided.
		if($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
			$webClient.UseDefaultCredentials = $true
		} else {
			$webClient.Credentials = $Credential
		}
	}

	process {
		$sug = Get-CMSoftwareUpdateGroup -Name $SoftwareUpdateGroupName | Select-Object -First 1

		$CI_UniqueID=$sug.CI_UniqueID

		foreach($state in $StateName) {

			$url = "http://$SrsServer/ReportServer?/ConfigMgr_$SiteCode/$ReportPathEncoded&rs:Format=$Format&CollID=$CollectionID&AuthListID=$CI_UniqueID&StateName=$state"
			([xml]$webClient.DownloadString($url)).Report.Table0.Detail_Collection.Detail |Foreach-object {
				[pscustomobject]@{
					AssignedSite = $_.Details_Table0_AssignedSite
					SoftwareUpdateGroup = $sug.LocalizedDisplayName
					ClientVersion = $_.Details_Table0_ClientVersion
					LastLoggedOnUser = $_.Details_Table0_LastLoggedOnUser
					MachineName = $_.Details_Table0_MachineName
					ADSiteName = $_.ADSiteName
					StateName = $state
				}
			}
		}
	}
}