@echo off
setlocal enabledelayedexpansion
for /f "skip=9 tokens=1,* delims=:" %%a in ('netsh wlan show profiles') do (
    set "profile=%%b"
    set "profile=!profile:~1!"
    netsh wlan show profile name="!profile!" key=clear | findstr "SSID Key Content"
)

pause