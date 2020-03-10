<#
.SYNOPSIS
    Adds a new Exagrid-based repository to Veeam

.DESCRIPTION
    This scripts adds an Exagrid appliance to the Veeam B&R system.
    It supports the work instructions in the team runbook.

.NOTES
    The script assumes that credentials have already been configured
    in Veeam for the Exagrid appliance. These credentials are named
    veeamdm (dm = data mover).

    The script must be run in the Veeam CLI environment, or the Veeam
    snap-in must be loaded some other way.

    When the script completes, a new Linux server (the Exagrid) and three
    new repositories (backup, retention and offsite) will exist in Veeam.

    Future improvement: Include code to setup the standard site jobs also.

.EXAMPLE
    Add-VeeamExagridRepository.ps1 -SiteCode JFV -ExagridName jfvsbk02-1.fmedical.net -VeeamNfsMountServer jfvveeamproxy1.fmedical.net
#>

param(
# The AD site code of the appliance location.
[parameter(Mandatory=$true)]
[string]$SiteCode,
# The FQDN of the Exagrid appliance.
[parameter(Mandatory=$true)]
[string]$ExagridName,
# This must be a valid Veeam proxy.
[parameter(Mandatory=$true)]
[string]$VeeamNfsMountServer
)

$FolderPathRoot = "/home/veeamd/$SiteCode"
$ExagridCredentials = Get-VbrCredentials -Name veeamdm

Add-VbrLinux -Name $ExagridName -Credentials $ExagridCredentials

Add-VBRBackupRepository -Name "$SiteName Backup" -Server $ExagridName -MountServer $VeeamNfsMountServer -Folder "$FolderPathRoot/backup" -Type ExaGrid -Credentials $ExagridCredentials -LimitConcurrentJobs -MaxConcurrentJobs 2

Add-VBRBackupRepository -Name "$SiteName Offsite" -Server $ExagridName -MountServer $VeeamNfsMountServer -Folder "$FolderPathRoot/offsite" -Type ExaGrid -Credentials $ExagridCredentials -LimitConcurrentJobs -MaxConcurrentJobs 2

Add-VBRBackupRepository -Name "$SiteName Retention" -Server $ExagridName -MountServer $VeeamNfsMountServer -Folder "$FolderPathRoot/retention" -Type ExaGrid -Credentials $ExagridCredentials -LimitConcurrentJobs -MaxConcurrentJobs 2
