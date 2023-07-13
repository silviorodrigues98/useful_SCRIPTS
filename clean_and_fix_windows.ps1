#Create restore point
Write-Output "Creating a restore point..."
try {
    Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"
    Write-Output "Restore point created successfully."
}
catch {
    Write-Output "Error creating restore point: $_"
}

# Run System File Checker
Write-Output "Running System File Checker..."
try {
    sfc /scannow
    Write-Output "System File Checker completed successfully."
}
catch {
    Write-Output "Error running System File Checker: $_"
}

# Run Deployment Image Servicing and Management
Write-Output "Running Deployment Image Servicing and Management..."
try {
    DISM.exe /Online /Cleanup-image /Restorehealth
    Write-Output "Deployment Image Servicing and Management completed successfully."
}
catch {
    Write-Output "Error running Deployment Image Servicing and Management: $_"
}

# Run Disk Cleanup
Write-Output "Running Disk Cleanup..."
try {
    cleanmgr.exe /sagerun:1
    Write-Output "Disk Cleanup completed successfully."
}
catch {
    Write-Output "Error running Disk Cleanup: $_"
}

# Clear temporary files
Write-Output "Clearing temporary files..."
try {
    Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "Temporary files cleared successfully."
}
catch {
    Write-Output "Error clearing temporary files: $_"
}

# Run a quick virus scan with Windows Defender
Write-Output "Running a quick virus scan with Windows Defender..."
try {
    Start-MpScan -ScanType QuickScan
    Write-Output "Virus scan completed successfully."
}
catch {
    Write-Output "Error running virus scan: $_"
}

# Check for and fix disk errors
Write-Output "Checking for and fixing disk errors..."
try {
    echo y | chkdsk C: /f /r
    Write-Output "Disk errors fixed successfully."
}
catch {
    Write-Output "Error fixing disk errors: $_"
}

# Clear DNS cache
Write-Output "Clearing DNS cache..."
try {
    ipconfig /flushdns
    Write-Output "DNS cache cleared successfully."
}
catch {
    Write-Output "Error clearing DNS cache: $_"
}

# Done
Write-Output "Done!"
