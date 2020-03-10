<#
    .Description
    Send an IT Service Desk notification
#>

function Send-SDNotification {
    param(
        [string]$From,
        [string[]]$To,
        [string]$Subject,
        [parameter(Mandatory,ParameterSetName='FromString')]
        [ValidateLength(0,5000)]
        [string]$BodyText,
        [ValidateScript({Test-Path $_})]
        [parameter(Mandatory,ParameterSetName='FromFile')]
        [string]$BodyFile,
        [string]$BrandImagePath = '',
        [string]$SmtpServer
    )

    $msg = New-Object Net.Mail.MailMessage
    $smtpClient = New-Object Net.Mail.SmtpClient($SmtpServer)

    $msg.From = $From
    $msg.To.Add($To)
    $msg.IsBodyHtml = $true
    $msg.Subject = $Subject

    $content = ''
    if($PsCmdlet.ParameterSetName -eq 'FromString') {
        $bodyHtml = "<p>"
        $bodyHtml += ($BodyText -replace "\n",'<br />' )
        $bodyHtml += "</p>"
        $content = 
@"
<html>
<head>
<style>
h1 {
    font-size: 14pt;
    font-family: Calibri, Arial;
}
p {
    font-size: 11pt;
    font-family: Calibri, Arial;
}
</style>
</head>
<body>
<h1>$Subject</h1>
<p>$BodyHtml</p>
</body>
</html>
"@

    } else {
        $content = Get-Content $BodyFile
    }
    # If brand image supplied, embed.
    if($BrandImagePath) {
        $file = Get-Item $BrandImagePath
        $ext = $file.Extension.Trim('.')
        $attachment = New-Object System.Net.Mail.Attachment -ArgumentList $BrandImagePath
        $attachment.ContentDisposition.Inline = $true
        $attachment.ContentDisposition.DispositionType = 'Inline'
        $attachment.ContentType.MediaType = "image/$ext"
        $attachment.ContentId = $file.ToString()
        $msg.Attachments.Add($attachment)
    }

    $msg.Body = $content
    $smtpClient.Send($msg)
    if($attachment) {$attachment.Dispose()}
    $msg.Dispose()
    $smtpClient.Dispose()
}