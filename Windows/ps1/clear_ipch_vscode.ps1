# Clean ipch folder for current user

# Get the user profile directory
$userProfileDirectory = $env:USERPROFILE

# Get the path to the VS Code ipch folder
$vscodeIpchFolder = Join-Path $userProfileDirectory ".vscode-cpptools\ipch"

# Delete all files in the VS Code ipch folder
Remove-Item -Path $vscodeIpchFolder -Force -Recurse

# Print a message to the console
Write-Host "Ipch folder cleared successfully!"
