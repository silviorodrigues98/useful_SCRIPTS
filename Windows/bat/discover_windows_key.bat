@echo off

REM Using wmic command
wmic path softwareLicensingService get OA3xOriginalProductKey
timeout /t 1

REM Using PowerShell command
powershell -Command "(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey"
timeout /t 1

REM Using registry (BackupProductKey)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v BackupProductKeyDefault

REM Using registry (DigitalProductId) - Might be empty on some systems
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v DigitalProductId

REM Check for OEM key in BIOS (Manufacturer specific)
setlocal enabledelayedexpansion

for /f "tokens=2*" %%a in ('wmic path Win32_ComputerSystemProduct get BIOSVersion') do set biosver=%%b

if defined biosver (
  echo Checking for OEM key in BIOS version !biosver! (Manufacturer specific)
  REM Replace "acer" with your manufacturer for specific commands (if available)
  wmic path softwarelicensingService get OA3xOriginalProductKey /nologo  > nul 2>&1  || echo OEM key check not supported by your manufacturer.
)

timeout /t 1

REM Additional command to display product key using slmgr.vbs
slmgr.vbs /dli

timeout /t 1

REM Pause for review
pause

