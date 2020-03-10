<#
    .Description
    Checks mandatory user account fields for invalid values
#>

# Rules: 
# givenName: Legal first name. Must contain only a-ZA-Z0-9
# surName: Legal last name, must contain only a-ZA-Z0-9
# userPrincipalName: givenName.surName@suffix
# mail: varies for JVs, but should match userPrincipalName everywhere else.
# Address fields: TBD
# Org fields: TBD
# Contact fields: TBD

param(
    [parameter(Mandatory,ValueFromPipeLine)]
    [string]$Identity,
    [string]$Suffix
)

process {
    $user = Get-ADUser -Identity $Identity -Properties mail
    if($user.givenName -match "\s") {
        write-error "$($user.name): Given name contains spaces."
    }
    if($user.surName -match "\s") {
        write-error "$($user.name): Surname contains spaces."
    }
    $upn = ($user.givenName -replace "\s","") + "." +
           ($user.surName -replace "\s","") + "@" +
           $Suffix 
    if($user.userPrincipalName -ne $upn) {
        write-error "$($user.name): UPN is not $upn"
    }
} 