Set-Location "C:\temp"
#.\PasswordChangeNotification.ps1  -smtpServer uit.telenet.be -expireInDays 21 -from "IT Support helpdesk@biopack.be" -Logging -LogPath "C:\temp\wachtwoorden" -testing -testRecipient alain@biopack.be

.\PasswordChangeNotification.ps1 -smtpServer "relay-auth.mailprotect.be" -expireInDays 21 -from "Biopack Helpdesk <helpdesk@biopack.be>" -Logging -LogPath "C:\temp\wachtwoorden" -reportTo ICT@biopack.be -interval 1,2,5,10,15 -testing alain@biopack.be
