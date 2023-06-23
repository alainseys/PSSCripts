@echo on

if '%username%' == 'gwendoline' goto IfStatement
if '%username%' == 'Ilse.Dereepere' goto IfStatement
if '%username%' == 'alain' goto IfStatement
goto ender

:IfStatement
del /q C:\Users\%username%\AppData\Roaming\Microsoft\Signatures
xcopy "\\fileserver\Signatures" "C:\Users\%username%\AppData\Roaming\Microsoft\Signatures" /exclude:except.txt /E /H /C /I


:ender
echo "voldoet niet aan voorwaarde"
pause.
