<#
.DESCRIPTION
Generate a file permission report on the given directory.

TODO: Incorporate this into the FMServer module.
#>
param(
[ValidateScript({Test-Path $_})]
[string]$Path,
[switch]$IncludeInherited=$false
)

function Get-FolderPermission {
param([string]$Path)

    $f = Get-Item $Path
    $acl = get-acl $f
    $acl.Access |? {$IncludeInherited -or $_.IsInherited -eq $false} |% {
        [pscustomobject]@{
            FolderName = $f.Name
            FolderPath = $f.FullName
            FileSystemRights = $_.FileSystemRights
            AccessControlType = $_.AccessControlType
            InheritanceFlags = $_.InheritanceFlags
            IdentityReference = $_.IdentityReference
        }
    }

    $subfolders = gci $Path -Directory
    foreach($folder in $subfolders) {
        Get-FolderPermission $folder.FullName
    }
}

Get-FolderPermission $Path