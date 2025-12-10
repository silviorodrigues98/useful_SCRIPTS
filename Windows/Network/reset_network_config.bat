@echo off
set DELAY=2
echo Releasing current IP address settings...
ipconfig /release
if %errorlevel% neq 0 (
    echo An error occurred while releasing the IP address settings.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Renewing IP address...
ipconfig /renew
if %errorlevel% neq 0 (
    echo An error occurred while renewing the IP address.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Deleting current hostname...
arp -d *
if %errorlevel% neq 0 (
    echo An error occurred while deleting the hostname.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Purging and reloading remote cache name table...
nbtstat -R
if %errorlevel% neq 0 (
    echo An error occurred while purging and reloading the remote cache name table.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Sending Name Release packets to WINS and starting refresh...
nbtstat -RR
if %errorlevel% neq 0 (
    echo An error occurred while sending Name Release packets to WINS and starting refresh.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Flushing DNS resolver cache...
ipconfig /flushdns
if %errorlevel% neq 0 (
    echo An error occurred while flushing the DNS resolver cache.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Initiating manual dynamic registration for DNS names and IP addresses...
ipconfig /registerdns
if %errorlevel% neq 0 (
    echo An error occurred while initiating manual dynamic registration for DNS names and IP addresses.
    exit /b %errorlevel%
)
ping localhost -n %DELAY% > nul
echo Done!
pause
