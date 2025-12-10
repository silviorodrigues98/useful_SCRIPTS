# Open the registry
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Check if the path exists
if (Test-Path $registryPath) {
    # Change the AUOptions value to 3 (Automatically download and notify of installation)
    Set-ItemProperty -Path $registryPath -Name AUOptions -Value 3
}
else {
    # If the path doesn't exist, create it
    New-Item -Path $registryPath -Force | Out-Null

    # Set the AUOptions value to 3
    Set-ItemProperty -Path $registryPath -Name AUOptions -Value 3
}
