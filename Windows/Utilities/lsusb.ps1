<#
.SYNOPSIS
    Lists USB devices similar to the Linux 'lsusb' command.

.DESCRIPTION
    This script retrieves information about connected USB devices using Get-PnpDevice.
    It parses the Vendor ID (VID) and Product ID (PID) from the device instance ID
    and formats the output to resemble the standard lsusb output.

.EXAMPLE
    .\lsusb.ps1
#>

$ErrorActionPreference = "SilentlyContinue"

# Get all present USB devices
$usbDevices = Get-PnpDevice -PresentOnly -Class USB

foreach ($device in $usbDevices) {
    # Attempt to parse VID and PID from InstanceId
    # Common format: USB\VID_XXXX&PID_XXXX\SSSSSS
    if ($device.InstanceId -match 'VID_([0-9A-F]{4})&PID_([0-9A-F]{4})') {
        $vendorId = $matches[1]
        $productId = $matches[2]
        
        # Format similar to lsusb: "Bus 000 Device 000: ID VID:PID FriendlyName"
        # Since Windows doesn't use Bus/Device numbers like Linux, we'll use a placeholder or check if we can get LocationInfo (often not generic).
        # We will use "Bus 000 Device 000" as a static label or just omit it to avoid confusion, 
        # but the request asked to be "similar to lsusb". 
        # Let's use the standard output format with simply valid IDs.
        
        Write-Output "Bus 000 Device 000: ID ${vendorId}:${productId} $($device.FriendlyName)"
    }
}
