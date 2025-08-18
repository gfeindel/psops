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
    Write-Verbose ("Processing {0}" -f $Path)
    $f = Get-Item $Path
    try {
        $acl = get-acl $f -ErrorAction Stop
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
    } catch {
        Write-Error ("Failed to retrieve ACL of {0}: {1}" -f $Path,$_.Exception.Message)
    }

    try {
        $subfolders = gci $Path -Directory -ErrorAction Stop
        foreach($folder in $subfolders) {
            Get-FolderPermission $folder.FullName
        }
    } catch {
        Write-Error ("Failed to process subfolders of {0}: {1}" -f $Path,$_.Exception.Message)
    }
}

Get-FolderPermission $Path
