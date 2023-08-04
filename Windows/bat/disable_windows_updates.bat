Here is the equivalent PowerShell script for the batch script you provided:

```powershell
# Stop the Windows Update service
Stop-Service -Name wuauserv

# Set the startup type of the Windows Update service to disabled
Set-Service -Name wuauserv -StartupType Disabled

# Disable automatic updates in Windows 11
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$propertyName = "NoAutoUpdate"
$propertyValue = 1

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
```

# Disable automatic updates in Windows
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$propertyName = "NoAutoUpdate"
$propertyValue = 1

# Create the registry path if it does not exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue

