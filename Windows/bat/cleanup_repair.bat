@echo off
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

for /f "skip=1 tokens=3" %%a in ('powershell "get-physicaldisk | format-table -autosize MediaType"') do (
    if "%%a"=="HDD" (
        echo Defragmenting C drive...
        defrag C: /U /V
    )else (
    echo Hard drive not detected, skipping Defrag
    )
)

echo Starting Windows MRT to remove malware
mrt.exe /f:Y /q:Y

echo Done!
pause
