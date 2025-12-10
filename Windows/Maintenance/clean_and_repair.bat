@echo off

echo Starting maintenance tasks... 
wmic.exe /namespace:\\root\default Path SystemRestore Call enable "C:\" 
if %errorlevel% == 0 (
    echo System Restore has been enabled on the C: drive. 
) else (
    echo An error occurred while enabling System Restore on the C: drive. 
)

echo Creating a restore point... 
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "clean_repair", 100, 12 

echo Running System File Checker... 
sfc /scannow 

echo Running Deployment Image Servicing and Management... 
dism.exe /online /cleanup-image /restorehealth 

echo Running Disk Cleanup... 
cleanmgr.exe /sagerun:1 

echo Checking for and fixing disk errors... 
echo y | chkdsk C: /f /r 

echo Clearing temporary files... 
del /f /s /q %TEMP%\* 
del /f /s /q C:\Windows\Temp\* 
del /f /s /q C:\Windows\Prefetch\* 
del /f /s /q C:\Windows\SoftwareDistribution\Download\* 

echo Clearing Microsoft Store cache... 
WSReset.exe 

for /f "skip=1 tokens=3" %%a in ('powershell "get-physicaldisk | format-table -autosize MediaType"') do (
    if "%%a"=="HDD" (
        echo Defragmenting C drive... 
        defrag C: /U /V 
    )else (
    echo Hard drive not detected, skipping Defrag 
    )
)

REM Set Power Management to Best Performance
echo Setting Power Management to Best Performance... 
powercfg /setactive scheme_min 

echo Done! 
pause
