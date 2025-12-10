@echo off

REM Reset OneDrive
start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe" /reset

REM Wait for OneDrive to reset
timeout /t 3 /nobreak >nul

REM Remove OneDrive folder
rmdir /s /q "%USERPROFILE%\OneDrive"

REM Remove OneDrive temp folder
rmdir /s /q "%LOCALAPPDATA%\Microsoft\OneDrive"

REM Remove OneDrive appdata folder
rmdir /s /q "%APPDATA%\Microsoft\OneDrive"

REM Remove OneDriveSetup folder
rmdir /s /q "%LOCALAPPDATA%\Microsoft\OneDriveSetup"

REM Remove OneDriveTemp folder
rmdir /s /q "%LOCALAPPDATA%\Microsoft\OneDriveTemp"
