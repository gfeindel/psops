<#
    .DESCRIPTION
    Report user and computer counts by OU within given root OU. An org might use this info
    to charge back some IT costs by user or computer.
#>
param(
$UserOU,
$ComputerOU
)

$sites = Get-ChildItem AD:\$userOU

$report = @{}

foreach($site in $sites) {
    $count = (Get-ADUser -Filter * -SearchBase $site.DistinguishedName | Measure-Object).Count
    $report[$site.Name] = $count
}

Write-Host "Users:"
$report

$report = @{}

$sites = Get-ChildItem AD:\$computerOU
foreach($site in $sites) {
    $count = (Get-ADComputer -Filter * -SearchBase $site.DistinguishedName | Measure-Object).Count
    $report[$site.Name] = $count
}

Write-Host "Computers:"
$report
