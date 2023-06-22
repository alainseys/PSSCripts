$createdSinceDate = ((Get-Date).AddDays(-31)).Date
$ou = 'OU=Domain Policy,DC=BIOPACK,DC=BE'


#Get-ADUser -Filter {whenCreated -ge $createdSinceDate} -Properties whenCreated -SearchBase $ou

Get-ADUser -Filter {whenCreated -ge $createdSinceDate} -Properties whenCreated -SearchBase $ou | Select-Object userprincipalname, whencreated | Sort-Object whencreated | Export-Csv C:\biopack\skip-created-users.csv -NoTypeInformation
