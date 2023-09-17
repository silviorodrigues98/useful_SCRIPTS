# Specify the location to save the backup
$backupPath = "C:\\RegistryBackup.reg"

# Export the entire registry
Write-Host "Creating a backup of your registry..."
reg export HKLM $backupPath
if ($?) {
    Write-Host "Registry backup has been created successfully at $backupPath"
} else {
    Write-Host "Failed to create a registry backup."
    exit
}

# Stop the Windows Update service
Stop-Service -Name wuauserv

# Set the startup type of the Windows Update service to disabled
Set-Service -Name wuauserv -StartupType Disabled

# Disable automatic updates via Local Group Policy Editor
Write-Host "Disabling automatic updates via Local Group Policy Editor..."
$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\{48981759-12F2-42A6-A048-028B3973495F}Machine\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$propertyName = "NoAutoUpdate"
$propertyValue = 1

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue

# Disable automatic updates via Registry
Write-Host "Disabling automatic updates via Registry..."
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
$propertyName = "AUOptions"
$propertyValue = 1

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
