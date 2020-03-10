<#
    .SYNOPSIS
    Purges items in a folder based on the specified criteria

    .PARAMETER Path
    The path to the folder that should be purged.

    .PARAMETER Filter
    The filter that matches names of files to be deleted.

    .PARAMETER MaxDays
    Files older than MaxDays will be deleted.
#>

function Purge-Folder {
    [CmdletBinding()]
    param(
    [string[]]
    $Path,
    [string]
    $Filter,
    [int]
    $MaxDays=0
    )

    begin {

    }

    process {
        foreach($p in $Path) {
            $maxd = (Get-Date).AddDays(-$MaxDays)
            $items = Get-ChildItem -Path $p -Filter $Filter |Where-Object {
                $_.LastWriteTime -lt $maxd
            }
            $items | Remove-Item -Verbose
            $numItems = ($items | Measure-Object).Count
            $sizeItems = ($items | Measure-Object -Property Length -Sum).Sum

            write-host "Deleted $numItems files and freed $sizeItems bytes."
        }
    }

    end {

    }
}