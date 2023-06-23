#verplaatsen van de lokale bestanden naar de remote server locatie 
$_sourcePath ="C:\temp\biopack\"
$_destinationPath = "\\fileserver\CODA bestanden";

#Bestand extensies
$_FileType= @("*cod*")
 
Get-ChildItem -recurse ($_sourcePath) -include ($_FileType) | move-Item -Destination ($_destinationPath)