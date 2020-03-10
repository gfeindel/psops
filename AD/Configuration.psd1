#Configuration data for Send-AuditEvent.ps1
@{

    Default = @{

        Subject = "Account Audit Event {EventID}"
        Message = "{Message}"
        Recipient = ''
    }
    '4625' = @{
        Subject = "Account Audit {EventId}: Failed Logon Detected on {Computer}: {TargetUserName}"
        Message = "{TargetUserName} failed to login from {WorkstationName} ({IpAddress}). Status Code: {Status}"
        Keywords = @("0xC0000234")
    }
    '4725' = @{
        Subject = "Account Audit {EventId}: {TargetUserName} disabled by {SubjectUserName}"
        Message = "{SubjectUserName} disabled the account {TargetUserName} ({TargetSid})"
    }
    '4740' = @{
	Subject = "Account Audit {EventId}: Account locked out on {TargetDomainName}: {TargetUserName}"
	Message = "{TargetUserName} was locked out when trying to login from {TargetDomainName}"
    }
    '4732' = @{
	Subject = "Account Audit {EventId}: {SubjectUserName} added a user to {TargetUserName}"
	Message = "{SubjectUserName} added the following user to {TargetUserName}:`n{MemberName}"
	Keywords = @("Admins","admin")
    }
    '4728' = @{
	Subject = "Account Audit {EventId}: {SubjectUserName} added a user to {TargetUserName}"
	Message = "{SubjectUserName} added the following user to {TargetUserName}:`n{MemberName}"
	Keywords = @("Admins","admin")
    }
    '4756' = @{
	Subject = "Account Audit {EventId}: {SubjectUserName} added a user to {TargetUserName}"
	Message = "{SubjectUserName} added the following user to {TargetUserName}:`n{MemberName}"
	Keywords = @("Admins","admin")
    }
}
