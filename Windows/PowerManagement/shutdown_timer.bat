@echo off
cls
echo ==================================================
echo      Shutdown / Restart Timer
echo ==================================================
echo.
echo 1. Shutdown
echo 2. Restart
echo 3. Cancel Scheduled Shutdown/Restart
echo.
set /p choice="Enter your choice (1/2/3): "

if "%choice%"=="3" goto cancel
if "%choice%"=="1" set action=shutdown
if "%choice%"=="2" set action=restart

if not defined action (
    echo Invalid choice.
    pause
    goto end
)

echo.
set /p minutes="Enter time in minutes (0 for immediately): "

:: Check if input is a number
set /a value=minutes
if not "%value%"=="%minutes%" (
    echo Invalid input. Please enter a number.
    pause
    goto end
)

set /a seconds=minutes*60

if "%action%"=="shutdown" (
    shutdown /s /t %seconds%
    echo System will shutdown in %minutes% minutes.
)

if "%action%"=="restart" (
    shutdown /r /t %seconds%
    echo System will restart in %minutes% minutes.
)

pause
goto end

:cancel
shutdown /a
echo Scheduled shutdown/restart cancelled.
pause

:end
exit
