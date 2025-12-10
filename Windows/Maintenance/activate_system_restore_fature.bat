@echo off
wmic.exe /namespace:\\root\default Path SystemRestore Call enable "C:\"
if %errorlevel% == 0 (
    echo System Restore has been enabled on the C: drive.
) else (
    echo An error occurred while enabling System Restore on the C: drive.
)
pause
