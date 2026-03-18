@echo off

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
if "%scrno%" == "8" goto loopend
  echo LEVEL %scrno%
  copy /b LEVEL%scrno%.MAC LEVEL.MAC >NUL
  REM %rt11exe% MACRO/LIST:DK:ROBIN%scrno% ROBIN.MAC /OBJECT:ROBIN%scrno%
  tools\macro11.exe ROBIN.MAC -l ROBIN%scrno%.lst -o ROBIN%scrno%.obj -rt11 -se -m SYSMAC.SML
  if not errorlevel 1 (
    echo LEVEL %scrno% COMPILED SUCCESSFULLY
  ) ELSE (
    findstr /RC:"^[ABDEILMNOPQRTUZ] " S1COMM.lst
    echo ======= %errdet% =======
    goto :Failed
  )
  del LEVEL.MAC
  tools\pclink11.exe ROBIN%scrno%.OBJ /MAP /VERBOSITY:1
  if errorlevel 1 (
    echo ======= LINK FAILED =======
    goto :Failed
  )
  for /f "delims=" %%a in ('findstr /B "Undefined globals" ROBIN%scrno%.MAP') do set "undefg=%%a"
  if not "%undefg%"=="" (
    echo ======= LINK FAILED: Undefined globals =======
    goto :Failed
  )
  echo LEVEL %scrno% LINKED SUCCESSFULLY
  del ROBIN%scrno%.OBJ
  rem del ROBIN%scrno%.LST
  set /a scrno += 1
goto loopscrno
:loopend

.\PrepareRobinDat\bin\Debug\net7.0\PrepareRobinDat.exe

echo. ESTRAT = .+2 > LEVEL.MAC
tools\macro11.exe ROBIN.MAC -l ROBIN.lst -o ROBIN.obj -rt11 -se -m SYSMAC.SML
if not errorlevel 1 (
  echo ROBIN COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " S1COMM.lst
  echo ======= %errdet% =======
  goto :Failed
)
del LEVEL.MAC

@if exist ROBIN.MAP del ROBIN.MAP
@if exist ROBIN.SAV del ROBIN.SAV

tools\pclink11.exe ROBIN.OBJ /MAP /VERBOSITY:1
if errorlevel 1 (
  echo ======= LINK FAILED =======
  goto :Failed
)
for /f "delims=" %%a in ('findstr /B "Undefined globals" ROBIN.MAP') do set "undefg=%%a"
if not "%undefg%"=="" (
  echo ======= LINK FAILED: Undefined globals =======
  goto :Failed
)
echo LINKED SUCCESSFULLY

echo %ESCchar%[92mDONE%ESCchar%[0m
exit

:Failed
@echo off
echo %ESCchar%[91mFAILED%ESCchar%[0m
exit /b
