' getSiteFromName.vbs
' Gabe Feindel
' Description
' Reads the first three chars of OSDComputerName to determine the AD site,
' and stores this in OSDLocation.

Option Explicit

Dim env
Dim osdComputerName
Dim defaultSite

set env = CreateObject("Microsoft.SMS.TSEnvironment")
osdComputerName = env("OSDComputerName")
defaultSite = "JFV"

if osdComputerName<>Empty then
	env("OSDLocation") = Left(OSDComputerName,3)
else
	env("OSDLocation") = defaultSite
end if
