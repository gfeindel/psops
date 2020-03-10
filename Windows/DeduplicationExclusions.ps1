#script to gather all deduplicated volumes, exclude Onenote filetypes and rehydrate those files

#set extension exclusions. Maybe tweak to gather existing exclusions first and keep those?
get-dedupvolume | ForEach-Object {set-dedupvolume -volume $_.Volume -excludefiletype "one, onetoc2, onebin,"}

#hydrate files
$files = get-dedupvolume | ForEach-Object {Get-ChildItem -Path $_.Volume -File -Recurse -filter "*.one"}
foreach ($file in $files) {Expand-DedupFile -Path $file.fullname}

#source: Get-ChildItem "Z:\Folder1", "Z:\Folder2" -File -Recurse | select FullName | ForEach-Object {Expand-DedupFile -Path $_.FullName}