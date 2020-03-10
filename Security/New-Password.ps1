# Reads a text-based dictionary file and generates passwords from it.

param(
[string]$FilePath='\\JFVFS1\IT$\Server\Reference\Scripts\create.txt',
[int]$Count=1
)

$words = gc $FilePath |? {$_.Length -gt 4 -and $_.Length -lt 6 -and -not ($_ -like "*'*")}
function New-Password {
    $t1 = Get-Random -Maximum ($words.Length-1)
    $t2 = Get-Random -Maximum ($words.Length-1)
    $t3 = Get-Random -Maximum 99
    $w1 = (Get-Culture).TextInfo.ToTitleCase($words[$t1])
    $w2 = (Get-Culture).TextInfo.ToTitleCase($words[$t2])
    $w1+$w2+("{0:00}" -f $t3)
}

1..$Count |% { New-Password }

#1..200 |% {New-Password}