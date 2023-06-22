#verplaatsen van de lokale bestanden naar de remote server locatie 
$_sourcePath ="C:\biopack\temp\biopack\"
$_destinationPath = "\\win2019-dc\H-drive\24 - Accounting\CODA bestanden";

#Bestand extensies
$_FileType= @("*cod*")
 
Get-ChildItem -recurse ($_sourcePath) -include ($_FileType) | move-Item -Destination ($_destinationPath)