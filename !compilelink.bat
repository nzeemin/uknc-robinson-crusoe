@echo off
set rt11exe=C:\bin\rt11\rt11.exe

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "DATESTAMP=%YYYY%-%MM%-%DD%"
for /f %%i in ('git rev-list HEAD --count') do (set REVISION=%%i)
echo V%REVISION% %DATESTAMP%

echo VERSTR:	.ASCII "V%REVISION% %DATESTAMP%" > VERSIO.MAC

@if exist ROBIN.LST del ROBIN.LST
@if exist ROBIN.OBJ del ROBIN.OBJ

echo TITLZS = 8192. > LEVELS.MAC
echo LEVELS:: .BLKW 42. >> LEVELS.MAC

set /a scrno = 1
:loopscrno
if "%scrno%" == "2" goto loopend
  echo LEVEL %scrno%
  copy /b LEVEL%scrno%.MAC LEVEL.MAC >NUL
  %rt11exe% MACRO/LIST:DK:ROBIN%scrno% ROBIN.MAC /OBJECT:ROBIN%scrno%
  for /f "delims=" %%a in ('findstr /B "Errors detected" ROBIN%scrno%.LST') do set "errdet=%%a"
  if "%errdet%"=="Errors detected:  0" (
    echo COMPILED SUCCESSFULLY
  ) ELSE (
    findstr /RC:"^[ABDEILMNOPQRTUZ] " ROBIN%scrno%.LST
    echo ======= %errdet% =======
    exit /b
  )
  del LEVEL.MAC
  %rt11exe% LINK ROBIN%scrno% /MAP:ROBIN%scrno%.MAP
  for /f "delims=" %%a in ('findstr /B "Undefined globals" ROBIN%scrno%.MAP') do set "undefg=%%a"
  if "%undefg%"=="" (
    rem type ROBIN%scrno%.MAP
    echo.
    echo LINKED SUCCESSFULLY
  ) ELSE (
    echo %ESCchar%[91m======= LINK FAILED =======%ESCchar%[0m
    exit /b
  )
  del ROBIN%scrno%.OBJ
  rem del ROBIN%scrno%.LST
  set /a scrno += 1
goto loopscrno
:loopend

.\PrepareRobinDat\bin\Debug\net7.0\PrepareRobinDat.exe

echo. > LEVEL.MAC
%rt11exe% MACRO/LIST:DK: ROBIN.MAC
for /f "delims=" %%a in ('findstr /B "Errors detected" ROBIN.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " ROBIN.LST
  echo ======= %errdet% =======
  exit /b
)
del LEVEL.MAC

@if exist ROBIN.MAP del ROBIN.MAP
@if exist ROBIN.SAV del ROBIN.SAV

%rt11exe% LINK ROBIN /MAP:ROBIN.MAP
for /f "delims=" %%a in ('findstr /B "Undefined globals" ROBIN.MAP') do set "undefg=%%a"
if "%undefg%"=="" (
  rem type ROBIN.MAP
  echo.
  echo %ESCchar%[92mLINKED SUCCESSFULLY%ESCchar%[0m
) ELSE (
  echo %ESCchar%[91m======= LINK FAILED =======%ESCchar%[0m
  exit /b
)

echo %ESCchar%[92mDONE%ESCchar%[0m
