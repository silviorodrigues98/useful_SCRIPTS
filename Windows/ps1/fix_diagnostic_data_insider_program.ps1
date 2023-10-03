# Open PowerShell with administrative privileges and run this script

# Define the path and name of the key
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
$name = "AllowTelemetry"

# Check if the key exists
if (Test-Path $path) {
    # Set the value of the key
    Set-ItemProperty -Path $path -Name $name -Value 3
}
else {
    # Create the key and set its value
    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name $name -Value 3 -PropertyType DWORD | Out-Null
}

# Restart the Connected User Experiences and Telemetry service
Restart-Service -Name DiagTrack

Write-Host "The script has been executed successfully."
