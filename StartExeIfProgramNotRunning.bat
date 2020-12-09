@ECHO OFF

SET EXEName=MSACCESS.exe
SET EXEFullPath=C:\temp\test folder with spaces\test.txt

TASKLIST | FINDSTR /I "%EXEName%"
IF ERRORLEVEL 1 GOTO :StartAutoImport
GOTO :EOF

:StartAutoImport
START "" "%EXEFullPath%"
GOTO :EOF