@echo off
setlocal enabledelayedexpansion

:menu
cls
set i=1
for /f "skip=9 tokens=4,* delims=: " %%a in ('netsh wlan show profiles') do (
    set profile[!i!]=%%a
    echo !i!. %%a
    set /a i+=1
)
echo.
set /p choice=Enter the number of the network profile to display the password: 
call :show_password "!profile[%choice%]!"
pause
goto menu

:show_password
set profile_name=%~1
set profile_name=%profile_name:~1%
netsh wlan show profile "%profile_name%" key=clear
goto :eof
