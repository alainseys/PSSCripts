Connect-VIServer -Server "" -User "" -Password ""
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$report = Get-View -ViewType VirtualMachine -Property Name,Guest,Runtime |
    Where-Object { $_.Runtime.PowerState -eq "poweredOn" } |
    Select-Object Name,
                  @{N='ToolsStatus';E={$_.Guest.ToolsStatus}},
                  @{N='ToolsType';E={$_.Guest.ToolsInstallType}},
                  @{N='ToolsVersion';E={$_.Guest.ToolsVersion}},
                  @{N='ToolsRunningStatus';E={$_.Guest.ToolsRunningStatus}},
                  @{N='vCenter';E={([uri]$_.Client.ServiceUrl).Host}} |
    Where-Object { $_.ToolsStatus -eq "toolsOld" -or $_.ToolsStatus -eq "toolsNotRunning" -or $_.ToolsStatus -eq "toolsNotInstalled" } | 
    Sort-Object -Property Name

$report | Select-Object Name | Export-Csv -Path "C:\temp\vm_list.csv" -NoTypeInformation


$sMail = @{
    To = ""
    From = ""
    Subject = "VM Tools Report"
    Body = $report | ConvertTo-Html | Out-String
    BodyAsHtml = $true
    SmtpServer = ""
}

Send-MailMessage @sMail
