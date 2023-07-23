# Set log file path
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path -Path $scriptPath -ChildPath "LogFile.txt"

# Function to write output to log file
function Write-Log([string]$message) {
    Add-Content -Path $logFile -Value $message
}

# Get network adapter information
Write-Host "Network Adapter Information:"
Get-NetAdapter | Format-Table -Property Name, InterfaceDescription, Status, LinkSpeed | Out-String | Write-Log

# Test network connection to a specific computer or IP address
$computerName = Read-Host -Prompt "Enter the computer name or IP address to test connection"
Write-Host "Testing connection to $computerName"
Test-NetConnection -ComputerName $computerName | Out-String | Write-Log

# Test connectivity based on port or service
$portNumber = Read-Host -Prompt "Enter the port number to test connectivity"
Write-Host "Testing connectivity to $computerName on port $portNumber"
Test-NetConnection -ComputerName $computerName -Port $portNumber | Out-String | Write-Log

# Trace route communications
Write-Host "Tracing route to $computerName"
Test-NetConnection -ComputerName $computerName -TraceRoute | Out-String | Write-Log

# Get IP configuration information
Write-Host "IP Configuration Information:"
Get-NetIPConfiguration | Format-Table -Property InterfaceAlias, InterfaceIndex, AddressFamily, IPAddress | Out-String | Write-Log

# Get DNS client server addresses
Write-Host "DNS Client Server Addresses:"
Get-DnsClientServerAddress | Format-Table -Property InterfaceAlias, AddressFamily, ServerAddresses | Out-String | Write-Log

# Get network connection profile information
Write-Host "Network Connection Profile Information:"
Get-NetConnectionProfile | Format-Table -Property InterfaceAlias, Name, NetworkCategory, IPv4Connectivity, IPv6Connectivity | Out-String | Write-Log

# Test network connection to a specific URL
$url = Read-Host -Prompt "Enter the URL to test connection"
Write-Host "Testing connection to $url"
Test-NetConnection -ComputerName $url -CommonTCPPort HTTP | Out-String | Write-Log
