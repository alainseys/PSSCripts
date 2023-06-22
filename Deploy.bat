@echo off
@break off
@color 0a
@cls


setlocal EnableDelayedExpansion

if not exist "%userprofile%\AppData\Roaming\Microsoft\Signatures" (
  mkdir "%userprofile%\AppData\Roaming\Microsoft\Signatures"
  if "!errorlevel!" EQU "0" (
    echo Creating Signature folder
  ) else (
    echo Error creating Signature folder
      
  )
) else (
  echo Signature folder already exists!
rem %SystemRoot%\explorer.exe "%userprofile%\AppData\Roaming\Microsoft\Signatures"


)

echo Moving files
xcopy /s "\\win2019-dc\H-drive\11 - IT\Signatures"  %userprofile%\AppData\Roaming\Microsoft\Signatures\ /Y
