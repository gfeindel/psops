<#
    .Description
    Sets UPN to GivenName.SurName@suffix
#>

[CmdletBinding()]
param(
    [parameter(Mandatory,ValueFromPipeline)]
    [string]$Identity,
    [string]$Suffix
)

process {
    $user = Get-ADUser $Identity
    if($null -ne $user) {
        $upn = $user.givenName + "." + 
               $user.surName +
               "@$suffix"
        if($upn -ne $user.userPrincipalName) {
            Write-Verbose ($user.userPrincipalName + " -> " + $upn)
            Set-ADUser -Identity $Identity -UserPrincipalName $upn
        } else {
            Write-Verbose ($user.userPrincipalName + " is correct.")
        }
    }
}