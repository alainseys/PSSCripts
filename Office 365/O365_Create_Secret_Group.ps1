#Creating of office 365 group that is truly hidden (not just private)

#without 2FA uncomment this
#$UserCredential = Get-Credential
#Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session

#with 2FA enabled
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
$EXOSession = New-ExoPSSession
Import-PSSession $EXOSession


New-UnifiedGroup -DisplayName "Secret Group" -Alias "SecretGroup" -EmailAddresses "email@address.com" -AccessType Private -HiddenGroupMembershipEnabled