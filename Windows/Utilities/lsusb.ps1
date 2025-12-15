<#
.SYNOPSIS
    Lists USB devices similar to the Linux 'lsusb' command.

.DESCRIPTION
    This script retrieves information about connected USB devices using Get-PnpDevice.
    It parses the Vendor ID (VID) and Product ID (PID) from the device instance ID
    and formats the output to resemble the standard lsusb output.
    
    Use the -Detailed (or -v) switch to see comprehensive properties for each device.

.PARAMETER Detailed
    Display detailed information about each device, including Manufacturer, Status, Class, etc.
    Alias: -v

.EXAMPLE
    .\lsusb.ps1
    Lists devices in short format.
    
.EXAMPLE
    .\lsusb.ps1 -v
    Lists devices with detailed information.
#>
[CmdletBinding()]
Param(
    [Alias('v')]
    [switch]$Detailed
)

$ErrorActionPreference = "SilentlyContinue"

# Get all present USB devices
$usbDevices = Get-PnpDevice -PresentOnly -Class USB

foreach ($device in $usbDevices) {
    # Attempt to parse VID and PID from InstanceId
    # Common format: USB\VID_XXXX&PID_XXXX\SSSSSS
    if ($device.InstanceId -match 'VID_([0-9A-F]{4})&PID_([0-9A-F]{4})') {
        $vendorId = $matches[1]
        $productId = $matches[2]
        
        Write-Output "Bus 000 Device 000: ID ${vendorId}:${productId} $($device.FriendlyName)"
        
        if ($Detailed) {
            Write-Output "  Device Descriptor:"
            Write-Output "    InstanceId:   $($device.InstanceId)"
            Write-Output "    Manufacturer: $($device.Manufacturer)"
            Write-Output "    Status:       $($device.Status)"
            Write-Output "    Class:        $($device.Class)"
            Write-Output "    Service:      $($device.Service)"
            Write-Output "    HardwareIDs:"
            foreach ($hwId in $device.HardwareID) {
                Write-Output "      $hwId"
            }
            Write-Output "    CompatibleIDs:"
            foreach ($cId in $device.CompatibleID) {
                Write-Output "      $cId"
            }
            Write-Output ""
        }
    }
}
