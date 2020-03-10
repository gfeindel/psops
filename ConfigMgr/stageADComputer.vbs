Option Explicit

Const ADS_SECURE_AUTHENTICATION = 1
Const DNS_DOMAIN = "" ' Domain to join
Const DN_DOMAIN = ""

dim objConnection ' Connection to query AD
dim objCommand ' ADODB query
dim objRecordSet ' Results of the command

dim OSDLocation, OSDComputerName, OSDChassisType ' OSD variables
dim prefix ' Computer name prefix
dim relativeName ' Relative LDAP path of the computer object
dim nameList ' Array of existing names matching prefix*

dim username, password ' For connection to AD. I know, hardcoding pwd is terrible.

' For connecting to AdsI provider.
dim objProvider
dim objContainer
dim objComputer

Set objConnection = CreateObject("ADODB.Connection")
objConnection.Open "Provider=ADsDSOObject;"

Set objCommand = CreateObject("ADODB.Command")
objCommand.ActiveConnection = objConnection

OSDLocation = env("OSDLocation")
OSDComputerName = env("OSDComputerName")
OSDChassisType = Left(env("OSDChassisType"),1) ' Must be Desktop or Laptop

'OSDLocation = ""
'OSDComputerName = ""
'OSDChassisType = "D"

prefix = OSDLocation&OSDChassisType

if OSDChassisType=Empty then
	OSDChassisType = "D" ' Assume desktop if no platform provided.
end if

if OSDComputerName<>Empty then
	Wscript.Quit 0
end if

' Else generate name automatically from AD.

objCommand.CommandText = _
 "<LDAP://DN>;(&(objectCategory=Computer)(name="&prefix&"*));name;subtree"
Set objRecordSet = objCommand.Execute

set nameList =  CreateObject("Scripting.Dictionary")

While Not objRecordSet.EOF
 	nameList.Add  objRecordSet("name").Value, ""
 	objRecordSet.MoveNext
Wend

dim i

' Look for available name
for i=0 to 9999
	dim testName
	testName = prefix & pad(i,4)
	if not nameList.Exists(testName) then
		wscript.echo "Found available name: " & testName
		OSDComputerName = testName
		exit for
	end if
next

' Add the name
username = ""
password = ""

' Create the object

'set objProvider = GetObject("LDAP:")
'relativeName = "CN="&OSDComputerName&",OU="&OSDLocation&",OU=Computers,OU=FMedical"
wscript.echo relativeName
'set objContainer = objProvider.OpenDSObject("LDAP://"&DNS_DOMAIN&"/"&DN_DOMAIN, username, password, ADS_SECURE_AUTHENTICATION)
'set objComputer = objContainer.Create("computer",relativeName)
'objComputer.Put "samAccountName",OSDComputerName&"$"
' TODO: Might need to set account control flags to enable the account?
'objComputer.SetInfo
' Set required properties to stage computer account, include DNS name and SAMAccountName.

' Set computer name only if could stage the object.
env("OSDComputerName") = OSDComputerName

function pad(val,length)
	dim sval, l
	sval = Cstr(val)
	l = Len(sval)
	if length<=l then
		pad = sval
	else
		pad = String(length-l,"0")&sval
	end if
end function
