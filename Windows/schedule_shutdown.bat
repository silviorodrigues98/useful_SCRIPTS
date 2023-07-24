@echo off
set /p datetime=Enter the date and time for shutdown (e.g. "07/23/2023 23:00"):
schtasks /delete /tn "Scheduled Shutdown" /f >nul 2>&1
if errorlevel 1 (
    echo No existing scheduled shutdown found
)
schtasks /create /tn "Scheduled Shutdown" /tr "shutdown.exe /s /f /t 0" /sc once /sd %datetime:~0,10% /st %datetime:~11,5%
if errorlevel 0 (
    echo Shutdown scheduled for %datetime%. To cancel, run this script again or run "schtasks /delete /tn "Scheduled Shutdown" /f"
) else (
    echo Failed to schedule shutdown
)
pause
