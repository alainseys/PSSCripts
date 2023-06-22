Get-MsolUser -All -ReturnDeletedUsers | Sort-Object DisplayName
Remove-MsolUser -UserPrincipalName "username@provider.com" -RemoveFromRecycleBin