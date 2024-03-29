# Specify the location of the backup
$backupPath = "C:\\RegistryBackup.reg"

# Specify the location of the log file
$logPath = "C:\\ScriptLog.txt"

# Redirect all output to the log file
Start-Transcript -Path $logPath -Append

# Import the registry backup
Write-Host "Restoring your registry from the backup..."
reg import $backupPath
if ($?) {
    Write-Host "Registry has been restored successfully from $backupPath"
} else {
    Write-Host "Failed to restore the registry."
    exit
}

# Start the Windows Update service
Start-Service -Name wuauserv

# Set the startup type of the Windows Update service to automatic
Set-Service -Name wuauserv -StartupType Automatic

# Enable automatic updates via Local Group Policy Editor
Write-Host "Enabling automatic updates via Local Group Policy Editor..."
$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\{48981759-12F2-42A6-A048-028B3973495F}Machine\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$propertyName = "NoAutoUpdate"
$propertyValue = 0

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue

# Enable automatic updates via Registry
Write-Host "Enabling automatic updates via Registry..."
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
$propertyName = "AUOptions"
$propertyValue = 4

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue

if ($?) {
    Write-Host "Automatic updates have been enabled successfully."
} else {
    Write-Host "Failed to enable automatic updates."
}

# Stop redirecting output to the log file
Stop-Transcript
