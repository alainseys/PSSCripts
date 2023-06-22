Set-Location "C:\temp"

.\PasswordChangeNotification.ps1 -smtpServer "smtp.provider.com" -expireInDays 21 -from "Helpdesk <helpdesk@domain.be>" -Logging -LogPath "C:\temp\password" -reportTo username@domain.com -interval 1,2,5,10,15 -testing yourusername@domain.com
