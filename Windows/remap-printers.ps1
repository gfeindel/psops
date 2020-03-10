[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$OldServer,
    [parameter(Mandatory=$true)]
    [string]$NewServer
)

$printers = Get-WmiObject Win32_Printer |? {$_.SystemName -like "\\$OldServer*"}

Write-Verbose "Remapping printers on $OldServer to $NewServer."

foreach($printer in $printers)
{
    $uncPath = $printer.Name 
    $default = $printer.Default
    $shareName = $printer.ShareName
    Write-Verbose "Deleting printer $uncPath"
    $printer.Delete()
    
    $newUncPath = "\\$NewServer\$ShareName"

    Write-Verbose "Remapping $newUncPath"
    ([wmiclass]'Win32_Printer').AddPrinterConnection($newUncPath)

    if($Default) {
        Write-Verbose "Setting $NewUncPath as default."        
        $p = Get-WmiObject Win32_Printer -Filter "Name='$($NewUncPath -replace '\\','\\')'"
        if($p) {$p.SetDefaultPrinter()}
    }
}