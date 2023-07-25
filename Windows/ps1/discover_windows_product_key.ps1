# Using wmic command
$wmicKey = (wmic path softwareLicensingService get OA3xOriginalProductKey)[2].Trim()

# Using PowerShell command
$psKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey

# Using registry
$regKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform").OA3xOriginalProductKey

# Display the keys
Write-Output "Windows Product Key (wmic): $wmicKey"
Write-Output "Windows Product Key (PowerShell): $psKey"
Write-Output "Windows Product Key (Registry): $regKey"
