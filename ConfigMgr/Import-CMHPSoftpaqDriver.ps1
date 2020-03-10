<# 
    .SYNOPSIS
        Imports HP Softpaq-based driver packages into ConfigMgr.
    .DESCRIPTION
        Import and categorize HP SOftpaqs into Configuration Manager 2012.
    .PARAMETER OS
        The OS version the driver applies to.
    .PARAMETER SoftpaqNumber
        The ID of the Softpaq. Looks like SPXXXXXX
    .PARAMTER UncDriverPath
        The root folder containing the driver folder structure described in Notes.
    .NOTES
        This script assumes that:
        1. You have created categories in ConfigMgr that match the platform name
           as HP defines it in the CVA file.
        2. You have created a driver folder structure that looks like this:
           Drivers Root folder
            win7
             HP
              SPxxxxx
            win10
             

        1.0 - Created
        1.1 - Fixed empty categories handling, improved comment-based help.
#>

param(
[parameter(ValueFromPipelineByPropertyName=$true)]
[ValidateSet("win7","win10")]
[string]$OS="win7",

[parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[ValidatePattern("sp\d{5}")]
[string]$SoftpaqNumber,

[string]$UncDriverPath
)

begin {
    function Get-SPAffectedPlatforms {
    <# 
        .SYNOPSIS
            Reads affected platforms from HP CVA file.
        .PARAMETER CvaFilePath
            The path to the CVA File.
        .NOTES
            The CVA file is an INI file. The platforms section lists affected platforms
            in the SysNameNN property. This reads all those lines and makes an array of 
            platform names.
    #>
    param(
    [string]$CvaFilePath
    )

        $platforms = @()
        
        $content = Select-String -pattern "SysName*" -Path $CvaFilePath
        $content |% {
            $list = $_.Line.Split("=")[1]
            $list.Split(",") |% {
                $platforms += $_.Trim()
            }
        }
        $platforms | Sort-Object
    }

}

process {
    $UncSpPath = "$UncDriverPath\$OS\HP\$SoftpaqNumber"
    $CvaPath = "$UncSpPath\$SoftpaqNumber.cva"

    if(-not (Test-Path Filesystem::$UncSpPath)) {
        write-error "$UncSpPath does not exist. Make sure the drivers were copied to the appropriate folder."
    }

    $affectedPlatforms = @()

    if(Test-Path Filesystem::$CvaPath) {
        $affectedPlatforms = Get-SPAffectedPlatforms -CvaFilePath Filesystem::$CvaPath
    } else {
        Write-Warning "Unable to determine affected platforms. $SoftpaqNumber.cva not found."
    }

    # Get existing platform categories from ConfigMgr.
    # If category does not exist, none is created.
    # Category names are of format <os> <platform>. <platform> must match
    # the platform name as defined in the CVA file, or the Win32_OperatingSystem.Model property.
    # For example: win7 HP EliteBook 840 G1
    $categories = @()
    foreach($platform in $affectedPlatforms) {
        $catname = "$OS $platform"
        $cat = Get-CMCategory -Name $catName -CategoryType DriverCategories
        if(-not $cat) {
            Write-Warning "No category defined for $catName"
        } else {
            $categories += $cat
        }
    }
    if($categories) {
        # Import the driver and assign categories.
        Import-CMDriver -UncFileLocation $UncSpPath -ImportFolder -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $true -AdministrativeCategory $categories
    } else {
        Import-CMDriver -UncFileLocation $UncSpPath -ImportFolder -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $true
    }

    [pscustomobject]@{
        SoftpaqNumber = $SoftpaqNumber
        OS = $OS
        DriverSource = $UncSpPath
        Platforms = $affectedPlatforms
    }
}
