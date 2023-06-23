Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "\\fileserver\deployment\Deploy.bat" & Chr(34), 0
Set WshShell = Nothing