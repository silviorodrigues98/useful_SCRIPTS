@echo off
setlocal enabledelayedexpansion

echo Converting CSV files to TXT files...
echo.

:: Check if any CSV files exist
dir /b *.csv >nul 2>&1
if errorlevel 1 (
    echo No CSV files found in current directory.
    goto :end
)

:: Counter for converted files
set "counter=0"

:: Process each CSV file
for %%F in (*.csv) do (
    set /a "counter+=1"
    echo Converting: %%F
    copy "%%F" "%%~nF.txt" >nul
)

echo.
echo Conversion complete! Converted %counter% file(s).

:end
pause