$principal = New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  # Create a restore point
Write-Output "Creating a restore point..."
try {
    # Use the Checkpoint-Computer cmdlet to create a new system restore point
    Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"
    Write-Output "Restore point created successfully."
}
catch {
    # Handle any errors that may occur
    Write-Output "Error creating restore point: $_"
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
    Write-Output "Error running System File Checker: $_"
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
    Write-Output "Error running Deployment Image Servicing and Management: $_"
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
    Write-Output "Error running Disk Cleanup: $_"
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
    Write-Output "Error fixing disk errors: $_"
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
    Write-Output "Error clearing temporary files: $_"
}

# Done 
Write-Output "Done!" 

} else {
  Start-Process -FilePath "powershell" -ArgumentList "$('-File \"\"')$(Get-Location)$('\\')$($MyInvocation.MyCommand.Name)$('\"\"')" -Verb runAs
}
