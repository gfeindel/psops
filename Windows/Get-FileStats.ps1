param(
[parameter(Mandatory=$true)]
[string]$Path
)

process {

# Bucket files based on last 12 months.
$buckets = @(1..12)
for($i=0; $i -lt 12; $i++) {
    $buckets[$i] = [pscustomobject]@{AccessFileCount=0;AccessFileSize=0;ModifyFileCount=0;ModifyFileSize=0}
}

$folders = New-Object System.Collections.ArrayList

if(-not (test-path $path)) {
    write-error "$path does not exist."
    return -1
}

$folders.Add($Path) | Out-Null

$today = Get-Date

while($folders.Count -gt 0) {

    $folder = $folders[0]
    $folders.RemoveAt(0)

    Get-ChildItem $folder -Directory |% {$folders.Add($_.FullName) | Out-Null}

    Get-ChildItem $folder -File |% {
    
        $lastAccessDays = ($today - $_.LastAccessTime).TotalDays
        $lastModifyDays = ($today - $_.LastWriteTime).TotalDays

        $lastAccessMo = [math]::Min([int]($lastAccessDays/30),11)
        $lastModifyMo = [math]::Min([int]($lastModifyDays/30),11)

        $buckets[$lastAccessMo].AccessFileCount += 1
        $buckets[$lastAccessMo].AccessFileSize += $_.Length
        $buckets[$lastModifyMo].ModifyFileCount += 1
        $buckets[$lastModifyMo].ModifyFileSize += $_.Length

    }

}

$buckets

}