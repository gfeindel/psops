<#
    .Description
    Initiates the ConfigMgr software updates deployment for the monthly updates.
#>
param(
    [ValidateScript({$_ -gt [datetime]::Now})]
    [ValidateNotNullOrEmpty()]
    [parameter(Mandatory)]
    [datetime]$Deadline,

    [ValidateNotNullOrEmpty()]
    [parameter(Mandatory)]
    [string]$CollectionName,

    [ValidateNotNullOrEmpty()]
    [string]$UpdateGroupBaseName = "Monthly Updates - Windows Server"
)

$d = [datetime]::Now
$dateFilter = $d.ToString("yyyy-MM")

$SUG = Get-CMSoftwareUpdateGroup -Name "$UpdateGroupBaseName $dateFilter*"
$DeploymentName = "$UpdateGroupBaseName Prod $dateFilter"

# Deploy to production servers
$parms = @{
    SoftwareUpdateGroupId = $SUG.CI_ID
    CollectionName = $CollectionName
    DeploymentName = $DeploymentName
    DeploymentType = 'Required'
    VerbosityLevel = 'OnlySuccessAndErrorMessages'
    TimeBasedOn = 'Utc'
    DeadlineDateTime = $Deadline
    UserNotification = 'DisplayAll'
    SoftwareInstallation = $true
    RestartServer = $false
    AcceptEula = $true
}
New-CMSoftwareUpdateDeployment @parms
