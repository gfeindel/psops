<# 
.SYNOPSIS
Import an IIS log file in W3C format.

.PARAMETER FilePath
The path to the log file(s)

#>

param(
    [ValidateScript({Test-Path $_})]
    [string[]]$FilePath
)

process {
    foreach($file in $FilePath) {
        # Read all non-comment lines.
        Get-Content $file |
        Where-Object {-not $_.StartsWith('#')} |
        ForEach-Object {
            $toks = $_.Split(' ')
            $parms = @{
                DateTime = (Get-Date ($toks[0] + ' ' + $toks[1]))
                ServerAddress = $toks[2]
                HttpMethod = $toks[3]
                UriStem = $toks[4]
                UriQuery = $toks[5]
                Port = $toks[6]
                User = $toks[7]
                ClientIp = $toks[8]
                UserAgent = $toks[9]
                Status = $toks[10]
                Substatus = $toks[11]
                Win32Status = $toks[12]
                TimeTaken = $toks[13]
            }
            # Support PS 2.0
            New-Object PSObject -Property $parms
        }
    }
}