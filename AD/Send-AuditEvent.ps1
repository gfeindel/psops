<#
.DESCRIPTION
Email an alert when this audit event is detected.

Templates control the formatting of alert messages. Templates
is a HashTable that uses the EventID as the Key. A template
defines the SUbject, Message, and REcipients.

You can insert properties of the event into the subject or message
field using insertion strings. Insertion strings use the format
{Key} where Key is the name of the field. Valid Key names are those
shown in the Data section of an event's XML. IN addition to these,
the script adds the name of the computer, the event id, and the 
default message as shown in the event log.

The Keywords field in the template lists key words or phrases that
must appear in the Message part of the event.

The Default template is used to format alerts for events that don't
have a specific template.
#>
param(
[string]$eventRecordID,
[string]$eventChannel,
[string]$SmtpServer,
[string]$From,
[ValidateScript({Test-Path $_})]
[string]$ConfigurationFile
)star

# Load $ConfigurationData
$item = Get-Item $ConfigurationFile
Import-LocalizedData -FileName $item.Name -BaseDirectory $item.DirectoryName -BindingVariable ConfigurationData

# Replaces insertion strings in $Message with the content in $Fields
# Insertion string is format {Name}. Name must be a key in $Fields.
function applyTemplate {
param(
[string]$Template,
[System.Collections.Hashtable]$Fields
)

    $s = $Template
    foreach($k in $Fields.Keys) {
        $s = $s -replace "{$k}",$Fields[$k]
    }
    return $s
}


# Retrieve the event that triggered this action.
$event = Get-WinEvent -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[(EventRecordID=$eventRecordID)]]</Select></Query></QueryList>"

$xmlEvent = [xml]$event.ToXml()

# Convert the XML to a hashtable for easier access to data.
$fields = @{}
$xmlEvent.Event.EventData.Data |% {
    $fields[$_.Name] = $_.InnerText
}
$fields['Computer'] = $event.MachineName
$fields['EventID'] = $event.Id
$fields['Message'] = $event.Message

$template = $ConfigurationData['Default']

# Generate the alert message from the template for this event ID.
if($ConfigurationData.ContainsKey($event.Id.ToString())) {
    $template = $ConfigurationData[$event.Id.ToString()]
}

$Subject = applyTemplate -Template $template.Subject -Fields $fields
$Message = applyTemplate -Template $template.Message -Fields $fields

$doProcess = $false

if($template.Keywords) {
	$template.Keywords |% {
    		if($event.Message -match $_) {
       	 	$doProcess = $true
    		}
	}
} else {
	$doProcess = $true
}

$Recipient = $ConfigurationData.Default.Recipient

if($template.Recipient) {
    $Recipient = $template.Recipient
}

write-host $doProcess

if($doProcess) {
@"
To: $Recipient
Subject: $Subject
Message: $Message
"@ | Write-Host
    Send-MailMessage -SmtpServer $SmtpServer -To $Recipient -From $From -Subject $Subject -Body $Message -Verbose
}
