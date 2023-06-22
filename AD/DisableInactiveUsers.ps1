#SingleUser
Import-Module ActiveDirectory
Disable-ADAccount -Identity userx

Import-Module ActiveDirectory
Import-Csv "C:\Users.csv" | ForEach-Object {
$samAccountName = $_."samAccountName"

#get-aduser will retrieve samAccountName from domain users. if we found it will disable else it will go to catch

try { Get-ADUser -Identity $samAccountName |
Disable-ADAccount  
}


catch {


  Write-Host "user:"$samAccountname "is not present in AD"
}
}