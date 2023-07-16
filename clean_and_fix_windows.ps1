# Create a restore point
Write-Output "Creating a restore point..."
try {
    # Use the Checkpoint-Computer cmdlet to create a new system restore point
    Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"
    Write-Output "Restore point created successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error creating restore point: $($_.Exception.Message)"
}

# Run System File Checker
Write-Output "Running System File Checker..."
try {
    # Use the sfc command to check for and repair any corrupted system files
    sfc /scannow
    Write-Output "System File Checker completed successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error running System File Checker: $($_.Exception.Message)"
}

# Run Deployment Image Servicing and Management
Write-Output "Running Deployment Image Servicing and Management..."
try {
    # Use the DISM command to check for and repair any issues with the Windows image
    DISM.exe /Online /Cleanup-image /Restorehealth
    Write-Output "Deployment Image Servicing and Management completed successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error running Deployment Image Servicing and Management: $($_.Exception.Message)"
}

# Run Disk Cleanup
Write-Output "Running Disk Cleanup..."
try {
    # Use the cleanmgr command to clean up unnecessary files on the disk
    cleanmgr.exe /sagerun:1
    Write-Output "Disk Cleanup completed successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error running Disk Cleanup: $($_.Exception.Message)"
}

# Run a quick virus scan with Windows Defender
Write-Output "Running a quick virus scan with Windows Defender..."
try {
    # Use the Start-MpScan cmdlet to start a quick virus scan with Windows Defender
    Start-MpScan -ScanType QuickScan
    Write-Output "Virus scan completed successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error running virus scan: $($_.Exception.Message)"
}

# Check for and fix disk errors
Write-Output "Checking for and fixing disk errors..."
try {
    # Use the chkdsk command to check for and fix any disk errors on the C: drive
    echo y | chkdsk C: /f /r
    Write-Output "Disk errors fixed successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error fixing disk errors: $($_.Exception.Message)"
}

# Clear temporary files
Write-Output "Clearing temporary files..."
try {
    # Use the Remove-Item cmdlet to delete temporary files from various locations on the disk
    Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\Prefetch\* -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\SoftwareDistribution\Download* -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Output "Temporary files cleared successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error clearing temporary files: $($_.Exception.Message)"
}

try {
    # Attempt to empty the Recycle Bin using the Clear-RecycleBin cmdlet
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin emptied successfully."
}
catch {
    # Handle any errors that may occur while emptying the Recycle Bin
    Write-Host "An error occurred while emptying the Recycle Bin: $($_.Exception.Message)"
}

try {
   
   # Attempt to clear Microsoft Store cache using WSReset.exe command 
   WSReset.exe 
   Write-Host "Microsoft Store cache cleared"
}
catch {
   # Handle any errors that may occur while clearing Microsoft Store cache 
   Write-Host "An error occurred while clearing Microsoft Store cache $($_.Exception.Message)"
}

# Clear DNS cache 
Write-Output "Clearing DNS cache..."
try { 
   # Use ipconfig command to flush DNS resolver cache 
   ipconfig /flushdns 
   Write-Output "DNS cache cleared successfully." 
} 
catch { 
   # Handle any errors that may occur while clearing DNS cache 
   Write-Output "Error clearing DNS cache: $($_.Exception.Message)" 
} 

# Done 
Write-Output "Done!" 
