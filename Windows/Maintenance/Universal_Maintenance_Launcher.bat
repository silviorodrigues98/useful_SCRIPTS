@echo off
:: Universal Maintenance Tool Launcher
:: Launches the PowerShell script with ExecutionPolicy Bypass to avoid permission errors.

echo Starting Universal Maintenance Tool...
echo.

:: Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"

:: Launch the PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Universal_Maintenance_Tool.ps1"

:: If the script creates a new window (due to elevation), this window might close immediately.
:: If it stays in the same window, this pause keeps it open if the script crashes.
if %errorlevel% neq 0 (
    echo.
    echo The script exited with an error.
    pause
)
