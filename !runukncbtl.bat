@echo off
set rt11dsk=C:\bin\rt11dsk

del x-ukncbtl\robin.dsk
@if exist "x-ukncbtl\robin.dsk" (
  echo.
  echo ####### FAILED to delete old disk image file #######
  exit /b
)
copy x-ukncbtl\sys1002ex.dsk robin.dsk
%rt11dsk% a robin.dsk ROBIN.SAV
%rt11dsk% a robin.dsk ROBIN.DAT
move robin.dsk x-ukncbtl\robin.dsk

@if not exist "x-ukncbtl\robin.dsk" (
  echo ####### ERROR disk image file not found #######
  exit /b
)

start x-ukncbtl\UKNCBTL.exe /boot
