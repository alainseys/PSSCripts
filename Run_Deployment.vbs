Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "\\win2019-dc\H-drive\11 - IT\deployment\Deploy.bat" & Chr(34), 0
Set WshShell = Nothing