Set-Location C:\biopack
$new_folder = Get-Date -Format "dd_MM_yyyy_HH_mm"

New-Item -ItemType Directory -Path C:\biopack\dhcpbackup\ -Name $new_folder

Backup-DhcpServer -path C:\biopack\dhcpbackup\$new_folder

Copy-Item C:\biopack\dhcpbackup\$new_folder\* -Destination \\WIN2019-DC\IT\Backups\dhcp\$new_folder\
Remove-Item C:\biopack\dhcpbackup\$new_folder -Recurse -Force -Confirm:$false