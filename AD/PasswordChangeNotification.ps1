<#
.Synopsis
   Script to Automated Email Reminders when Users Passwords due to Expire.
.DESCRIPTION
   Script to Automated Email Reminders when Users Passwords due to Expire.
   Robert Pearman / WindowsServerEssentials.com
   Version 2.9 August 2018
   Requires: Windows PowerShell Module for Active Directory
   For assistance and ideas, visit the TechNet Gallery Q&A Page. http://gallery.technet.microsoft.com/Password-Expiry-Email-177c3e27/view/Discussions#content

   Alternativley visit my youtube channel, https://www.youtube.com/robtitlerequired

   Videos are available to cover most questions, some videos are based on the earlier version which used static variables, however most of the code
   can still be applied to this version, for example for targeting groups, or email design.

   Please take a look at the existing Q&A as many questions are simply repeating earlier ones, with the same answers!


.EXAMPLE
  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -Logging -LogPath "c:\logFiles" -testing -testRecipient support@domain.com
  
  This example will use mail.domain.com as an smtp server, notify users whose password expires in less than 21 days, send mail from support@domain.com
  Logging is enabled, log path is c:\logfiles
  Testing is enabled, and test recipient is support@domain.com

.EXAMPLE
  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -reportTo myaddress@domain.com -interval 1,2,5,10,15
  
  This example will use mail.domain.com as an smtp server, notify users whose password expires in less than 21 days, send mail from support@domain.com
  Report is enabled, reports sent to myaddress@domain.com
  Interval is used, and emails will be sent to people whose password expires in less than 21 days if the script is run, with 15, 10, 5, 2 or 1 days remaining untill password expires.

#>
param(
    # $smtpServer Enter Your SMTP Server Hostname or IP Address
    [Parameter(Mandatory=$True,Position=0)]
    [ValidateNotNull()]
    [string]$smtpServer,
    # Notify Users if Expiry Less than X Days
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateNotNull()]
    [int]$expireInDays,
    # From Address, eg "IT Support <support@domain.com>"
    [Parameter(Mandatory=$True,Position=2)]
    [ValidateNotNull()]
    [string]$from,
    [Parameter(Position=3)]
    [switch]$logging,
    # Log File Path
    [Parameter(Position=4)]
    [string]$logPath,
    # Testing Enabled
    [Parameter(Position=5)]
    [switch]$testing,
    # Test Recipient, eg recipient@domain.com
    [Parameter(Position=6)]
    [string]$testRecipient,
    # Output more detailed status to console
    [Parameter(Position=7)]
    [switch]$status,
    # Log file recipient
    [Parameter(Position=8)]
    [string]$reportto,
    # Notification Interval
    [Parameter(Position=9)]
    [array]$interval
)
###################################################################################################################
# Time / Date Info
###################################################################################################################
$start = [datetime]::Now
$midnight = $start.Date.AddDays(1)
$timeToMidnight = New-TimeSpan -Start $start -end $midnight.Date
$midnight2 = $start.Date.AddDays(2)
$timeToMidnight2 = New-TimeSpan -Start $start -end $midnight2.Date
# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$today = $start
# End System Settings
###################################################################################################################
# Load AD Module
###################################################################################################################
try{
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch{
    Write-Warning "Unable to load Active Directory PowerShell Module"
}
###################################################################################################################
# Set Output Formatting - Padding characters
###################################################################################################################
$padVal = "20"
Write-Output "Script Loaded"
Write-Output "*** Settings Summary ***"
$smtpServerLabel = "SMTP Server".PadRight($padVal," ")
$expireInDaysLabel = "Expire in Days".PadRight($padVal," ")
$fromLabel = "From".PadRight($padVal," ")
$testLabel = "Testing".PadRight($padVal," ")
$testRecipientLabel = "Test Recipient".PadRight($padVal," ")
$logLabel = "Logging".PadRight($padVal," ")
$logPathLabel = "Log Path".PadRight($padVal," ")
$reportToLabel = "Report Recipient".PadRight($padVal," ")
$interValLabel = "Intervals".PadRight($padval," ")
# Testing Values
if($testing)
{
    if(($testRecipient) -eq $null)
    {
        Write-Output "No Test Recipient Specified"
        Exit
    }
}
# Logging Values
if($logging)
{
    if(($logPath) -eq $null)
    {
        $logPath = $PSScriptRoot
    }
}
###################################################################################################################
# Output Summary Information
###################################################################################################################
Write-Output "$smtpServerLabel : $smtpServer"
Write-Output "$expireInDaysLabel : $expireInDays"
Write-Output "$fromLabel : $from"
Write-Output "$logLabel : $logging"
Write-Output "$logPathLabel : $logPath"
Write-Output "$testLabel : $testing"
Write-Output "$testRecipientLabel : $testRecipient"
Write-Output "$reportToLabel : $reportto"
Write-Output "$interValLabel : $interval"
Write-Output "*".PadRight(25,"*")
###################################################################################################################
# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
###################################################################################################################
# Create arry to store User
$users = @()
###################################################################################################################
# Create array to store groups / Group based targetting
###################################################################################################################
$groups = @(
   "cc.vmt.11"

)
foreach($group in $groups){
    $members = Get-AdGroupMember $group
    #$members | Select SamAccountName
    #$members | Select Name
    foreach($member in $members){
        $user = Get-ADUser $member -properties Name, GivenName, SurName,PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress, PreferredLanguage, Manager
        $users += $user
    }
}
###################################################################################################################
# Count Users
###################################################################################################################
$usersCount = ($users | Measure-Object).Count
Write-Output "Found $usersCount User Objects"
# Collect Domain Password Policy Information
$defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days 
Write-Output "Domain Default Password Age: $defaultMaxPasswordAge"
# Collect Users
$colUsers = @()

# Process Each User for Password Expiry
Write-Output "Process User Objects"
foreach ($user in $users)
{
    # Get user info
    $managerDN = $user.Manager
    if($managerDN){
        $mangerDetails = Get-AdUser -Identity $managerDN -Properties EmailAddress, GivenName, DisplayName, SurName
        $managerFirstName = $mangerDetails.GivenName
        $managerLastName = $managerDetails.LastName
        $managerDisplayName = $mangerDetails.DisplayName
        $managerEmail = $managerDetails.EmailAddress
    }else{
        $noinfo = "N/A"
        $managerFirstName = $noinfo
        $managerLastName = $noinfo
        $managerDisplayName = $noinfo
        $managerEmail = $noinfo
    }
    ###################################################################################################################
    # Store User information
    ###################################################################################################################
    $Name = $user.Name
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $samAccountName = $user.SamAccountName
    $pwdLastSet = $user.PasswordLastSet
    $passwordNeverExpires  = $user.PasswordNeverExpires
    $FirstName = $user.GivenName
    $LastName = $user.Surname
    ###################################################################################################################
    # Check for Fine Grained Password
    ###################################################################################################################
    $maxPasswordAge = $defaultMaxPasswordAge
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user) 
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge.Days
    }
    ###################################################################################################################
    # Create User Object
    ###################################################################################################################
    $userObj = New-Object System.Object
    ###################################################################################################################
    # Handeling password never expire
    ###################################################################################################################
    if($passwordNeverExpires -eq $true){
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value 1 # Fix for PasswordNeverExpires
        $userObj | Add-Member -Type NoteProperty -Name DaysToExpire -Value 1
        $userObj | Add-Member -Type NoteProperty -Name ExpiresOn -Value $today
    }else{
        $expireson = $pwdLastSet.AddDays($maxPasswordAge)
        $daysToExpire = New-TimeSpan -Start $today -End $expireson
            # Round Expiry Date Up or Down
        if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -le $timeToMidnight.TotalHours))
        {
            $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "today."
        }
        if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -gt $timeToMidnight.TotalHours) -or ($daysToExpire.Days -eq "1") -and ($daysToExpire.TotalHours -le $timeToMidnight2.TotalHours))
        {
            $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "tomorrow."
        }
        if(($daysToExpire.Days -ge "1") -and ($daysToExpire.TotalHours -gt $timeToMidnight2.TotalHours))
        {
            $days = $daysToExpire.TotalDays
            $days = [math]::Round($days)
            $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "in $days days."
        }
        $daysToExpire = [math]::Round($daysToExpire.TotalDays)
        $userObj | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daysToExpire
        $userObj | Add-Member -Type NoteProperty -Name ExpiresOn -Value $expiresOn
    }
    # Add remaining properteis to userObj
    $userObj | Add-Member -Type NoteProperty -Name UserName -Value $samAccountName
    $userObj | Add-Member -Type NoteProperty -Name Name -Value $Name
    $userObj | Add-Member -Type NoteProperty -Name EmailAddress -Value $emailAddress
    $userObj | Add-Member -Type NoteProperty -Name PasswordSet -Value $pwdLastSet
    $userObj | Add-Member -Type NoteProperty -Name PreferredLanguage -Value $user.PreferredLanguage  # New property for preferred language
    $colUsers += $userObj
}
# Count Users
$colUsersCount = ($colUsers | Measure-Object).Count

Write-Output "$colusersCount Gebruikers Verwerkt"
# Select Users to Notify
$notifyUsers = $colUsers | where { $_.DaysToExpire -le $expireInDays}
$notifiedUsers = @()
$notifyCount = ($notifyUsers | Measure-Object).Count
Write-Output "$notifyCount Gebruiker met verlopen wachtwoorden binnen $expireInDays dagen"
# Process notifyusers
foreach ($user in $notifyUsers)
{
    # Email Address
    $samAccountName = $user.UserName
    $emailAddress = $user.EmailAddress
    #Check if email address is null
    if(-not $emailaddress){
        Write-Output "Email address is null for user $($user.name)"
    }

    # Set Greeting Message
    $name = $user.Name
    $messageDays = $user.UserMessage
    # Subject Setting
    $subject="Uw wachtwoord zal verlopen binnen $messageDays dagen - Vortre mot de pas expira dans $messageDays jours " 
       
}
    $templateDirectory = "html"

    foreach($user in $notifyUsers){
        $preferredLanguage = $user.PreferredLanguage

        #Set Default language
        if([string]::IsNullOrEmpty($preferredLanguage)){
            $preferredLanguage = "en-US"
        }
        # Consturct the template
        $templatePath = Join-Path $templateDirectory "$preferredLanguage.html"

        # Check if the file exists
        if(-not (Test-Path $templatePath)){
            Write-Output "Template for $preferredLanguage was not found"
            $templatePath = Join-Path $templateDirectory "en-US.html"
        }
        # Load the template file content
        $body = Get-Content -Path $templatePath -Raw

        # Replace the placeholders in the template with the actual user data
        $body = $body -replace "{{UserName}}", $user.Name
        $body = $body -replace "{{DaysToExpire}}", $user.DaysToExpire
        $body = $body -replace "{{ManagerEmail}}", $user.ManagerEmail
        $body = $body -replace "{{PasswordLastSet}}", $passwordSetDate
        $body = $body -replace "{{FirstName}}", $FirstName
        $body = $body -replace "{{LastName}}", $LastName
        # Add Manager Placeholders
        $body = $body -replace "{{ManagerFirstName}}", $managerFirstName
        $body = $body -replace "{{ManagerLastName}}", $managerLastName
        $body = $body -replace "{{ManagerEmail}}", $managerEmail

        # Log the used template
        Write-Output "Using Template: $templatePath for $FirstName $LastName"

    # If Testing Is Enabled - Email Administrator
    if($testing)
    {
        $emailaddress = $testRecipient
    } # End Testing
    # If a user has no email address listed
    if(($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }# End No Valid Email
    $samLabel = $samAccountName.PadRight($padVal," ")
    try{
        # If using interval paramter - follow this section
        if($interval)
        {
            $daysToExpire = [int]$user.DaysToExpire
            # check interval array for expiry days
            if(($interval) -Contains($daysToExpire))
            {
                # if using status - output information to console
                if($status)
                {
                    Write-Output "Sending Email : $samLabel : $emailAddress"
                }
                # Send message - if you need to use SMTP authentication watch this video https://youtu.be/_-JHzG_LNvw
                Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop
                $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "OK"
            }
            else
            {
                # if using status - output information to console
                # No Message sent
                if($status)
                {
                    Write-Output "Sending Email : $samLabel : $emailAddress : Skipped - Interval"
                }
                $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "Skipped - Interval"
            }
        }
        else
        {
            # if not using interval paramter - follow this section
            # if using status - output information to console
            if($status)
            {
                Write-Output "Sending Email : $samLabel : $emailAddress"
            }
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop
            $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "OK"
        }
    }
    catch{
        # error section
        $errorMessage = $_.exception.Message
        # if using status - output information to console
        if($status)
        {
           $errorMessage
        }
        $user | Add-Member -MemberType NoteProperty -Name SendMail -Value $errorMessage    
    }
    $notifiedUsers += $user
}
if($logging)
{
    # Create Log File
    Write-Output "Creating Log File"
    $day = $today.Day
    $month = $today.Month
    $year = $today.Year
    $date = "$day-$month-$year"
    $logFileName = "$date-PasswordLog.csv"
    if(($logPath.EndsWith("\")))
    {
       $logPath = $logPath -Replace ".$"
    }
    $logFile = $logPath, $logFileName -join "\"
    Write-Output "Log Output: $logfile"
    $notifiedUsers | Export-CSV $logFile
    if($reportTo)
    {
        $reportSubject = "Password Expiry Report"
        $reportBody = "Password Expiry Report Attached"
        try{
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $reportTo -subject $reportSubject -body $reportbody -bodyasHTML -priority High -Encoding $textEncoding -Attachments $logFile -ErrorAction Stop 
        }
        catch{
            $errorMessage = $_.Exception.Message
            Write-Output $errorMessage
        }
    }
}
#$notifiedUsers | select UserName,Name,EmailAddress,PasswordSet,DaysToExpire,ExpiresOn | sort DaystoExpire | FT -autoSize
$notifiedUsers | Select-Object UserName, Name, EmailAddress, PasswordSet, DaysToExpire, ExpiresOn, PreferredLanguage | Sort-Object DaysToExpire | Format-Table -autoSize
$stop = [datetime]::Now
$runTime = New-TimeSpan $start $stop
Write-Output "Script Runtime: $runtime"
# End
