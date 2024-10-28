@echo off
setlocal enabledelayedexpansion

echo Retrieving Microsoft Office Product Keys...
echo.

:: Define Office versions and their corresponding paths
set "versions=16 15 14 12 11"
set "version_names=2016-2021 2013 2010 2007 2003"

:: Check Windows architecture
if exist "%ProgramFiles(x86)%" (
    set "arch=64"
) else (
    set "arch=32"
)

:: Function to check if a path exists and run the command
for %%v in (%versions%) do (
    call :check_office_version %%v
)

echo.
echo Finished checking all Office versions.
pause
exit /b 0

:check_office_version
set "office_ver=%~1"
set "path32bit=%ProgramFiles%\Microsoft Office\Office%office_ver%\OSPP.vbs"
set "path64bit=%ProgramFiles(x86)%\Microsoft Office\Office%office_ver%\OSPP.vbs"

:: Get version name for display
for /f "tokens=%office_ver% delims= " %%a in ("%version_names%") do set "ver_name=%%a"

echo Checking Office %ver_name%...

if "%arch%"=="64" (
    :: Check 64-bit Windows paths
    if exist "!path64bit!" (
        echo Found 32-bit Office %ver_name% on 64-bit Windows
        cscript "!path64bit!" /dstatus
    )
    if exist "!path32bit!" (
        echo Found 64-bit Office %ver_name% on 64-bit Windows
        cscript "!path32bit!" /dstatus
    )
) else (
    :: Check 32-bit Windows path
    if exist "!path32bit!" (
        echo Found 32-bit Office %ver_name% on 32-bit Windows
        cscript "!path32bit!" /dstatus
    )
)

echo.
exit /b 0