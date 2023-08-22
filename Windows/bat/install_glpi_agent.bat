@echo off

REM Uninstall GLPI Agent
powershell.exe -Command "& { $productCode = (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like 'GLPI Agent*'}).IdentifyingNumber; msiexec.exe /x $productCode /quiet }"

timeout /t 5 /nobreak 

REM Set the server URL
set SERVER_URL=https://glpi.thetasigma.online/front/inventory.php

REM Set the search directory to the actual folder of the script
set SEARCH_DIRECTORY=%~dp0

REM Set the search pattern for the MSI file
set SEARCH_PATTERN=GLPI-Agent-*.msi

REM Search for the MSI file
for /R "%SEARCH_DIRECTORY%" %%f in (%SEARCH_PATTERN%) do (
    set MSI_FILE=%%f
    goto :install
)

echo GLPI Agent MSI file not found
goto :end

:install
REM Install GLPI Agent
msiexec.exe /i "%MSI_FILE%" /quiet RUNNOW=1 SERVER="%SERVER_URL%" ADD_FIREWALL_EXCEPTION=1

echo GLPI Agent installed, you can access it on http://localhost:62354

:end
pause
