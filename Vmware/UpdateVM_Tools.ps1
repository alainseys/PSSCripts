connect-viserver "" -User "" -Password ""
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$cluster_name = "EDC-PROD"

#Import vm from csv
Import-Csv "C:\temp\vm_list.csv" | foreach {
      $strNewVMName = $_.name
      #Update VMtools without reboot
      Get-Cluster $cluster_name | Get-VM $strNewVMName | Update-Tools –NoReboot 
      write-host "Updated $strNewVMName ------ "
      $report += $strNewVMName
}
write-host "Sleeping ..."
Sleep 120

$sMail = @{
    To = ""
    From = ""
    Subject = ""
    Body = $report | ConvertTo-Html | Out-String
    BodyAsHtml = $true
    SmtpServer = ""
}

Send-MailMessage @sMail