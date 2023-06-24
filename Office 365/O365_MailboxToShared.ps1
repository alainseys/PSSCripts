#Convert mailbox to shared mailbox and remove the licence
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$usermailbox = read-Host 'Users mailbox to convert to shared mailbox'
$supervisor = read-Host 'User who is going to be having access to shared mailbox'

Set-Mailbox $usermailbox -Type shared

#microsoft is a bit slow while doing this so we need to add some sleep time 

start-sleep -s 90

#adjustment of licences
Add-MailboxPermission -Identity $usermailbox -User $supervisor -AccessRights FullAccess
connect-msolservice -credential $UserCredential
Set-MsolUserLicense -UserPrincipalName "$usermailbox" -RemoveLicenses YOURO365NAME:EXCHANGESTANDARD
Set-MsolUserLicense -UserPrincipalName "$usermailbox" -RemoveLicenses YOURO365NAME:O365_BUSINESS