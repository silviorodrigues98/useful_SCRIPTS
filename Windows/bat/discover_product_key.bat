@echo off

REM Using wmic command
wmic path softwareLicensingService get OA3xOriginalProductKey
timeout /t 1

REM Using PowerShell command
powershell -Command "(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey"
timeout /t 1

REM Using registry
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v BackupProductKeyDefault

pause