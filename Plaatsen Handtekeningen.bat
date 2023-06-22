@echo on

if '%username%' == 'gwendoline' goto IfStatement
if '%username%' == 'Ilse.Dereepere' goto IfStatement
if '%username%' == 'alain' goto IfStatement
goto ender

:IfStatement
del /q C:\Users\%username%\AppData\Roaming\Microsoft\Signatures
xcopy "C:\Users\%username%\AppData\Roaming\Microsoft\Signatures" "\\win2019-dc\H-drive\11 - IT\Signatures" /exclude:except.txt /E /H /C /I

:ender
echo "voldoet niet aan voorwaarde"
pause.
