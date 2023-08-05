@echo off
set log=%~dp0\maintenance.log

echo Starting maintenance tasks... >> %log%
wmic.exe /namespace:\\root\default Path SystemRestore Call enable "C:\" >> %log%
if %errorlevel% == 0 (
    echo System Restore has been enabled on the C: drive. >> %log%
) else (
    echo An error occurred while enabling System Restore on the C: drive. >> %log%
)

echo Creating a restore point... >> %log%
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "clean_repair", 100, 12 >> %log%

echo Running System File Checker... >> %log%
sfc /scannow >> %log%

echo Running Deployment Image Servicing and Management... >> %log%
dism.exe /online /cleanup-image /restorehealth >> %log%

echo Running Disk Cleanup... >> %log%
cleanmgr.exe /sagerun:1 >> %log%

echo Checking for and fixing disk errors... >> %log%
echo y | chkdsk C: /f /r >> %log%

echo Clearing temporary files... >> %log%
del /f /s /q %TEMP%\* >> %log%
del /f /s /q C:\Windows\Temp\* >> %log%
del /f /s /q C:\Windows\Prefetch\* >> %log%
del /f /s /q C:\Windows\SoftwareDistribution\Download\* >> %log%

echo Clearing Microsoft Store cache... >> %log%
WSReset.exe >> %log%

for /f "skip=1 tokens=3" %%a in ('powershell "get-physicaldisk | format-table -autosize MediaType"') do (
    if "%%a"=="HDD" (
        echo Defragmenting C drive... >> %log%
        defrag C: /U /V >> %log%
    )else (
    echo Hard drive not detected, skipping Defrag >> %log%
    )
)

REM Set Power Management to Best Performance
echo Setting Power Management to Best Performance... >> %log%
powercfg /setactive scheme_min >> %log%

echo Done! >> %log%
pause
