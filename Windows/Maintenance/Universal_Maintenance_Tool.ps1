<#
.SYNOPSIS
    Universal Windows Maintenance and Repair Tool
    Combines cleaning, repair, and optimization tasks into a single menu-driven script.

.DESCRIPTION
    This script provides a comprehensive set of tools to maintain Windows systems:
    - System Restore management
    - System File Checker (SFC)
    - DISM Image Repair
    - Disk Cleanup and Error Checking
    - Network Reset
    - Windows Update Reset
    - Temporary File Cleanup
    
.NOTES
    Run as Administrator.
#>

# ---------------------------------------------------------------------------
# Self-Elevation to Administrator
# ---------------------------------------------------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    try {
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
        exit
    }
    catch {
        Write-Error "Failed to elevate. Please run this script as Administrator."
        pause
        exit
    }
}

# ---------------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------------

function Show-Header {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "           WINDOWS UNIVERSAL MAINTENANCE TOOL               " -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Script {
    Write-Host ""
    Write-Host "Press any key to return to the menu..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ---------------------------------------------------------------------------
# Core Functions
# ---------------------------------------------------------------------------

function Enable-SystemRestore {
    Show-Header
    Write-Host "Enabling System Restore on C: drive..." -ForegroundColor Yellow
    try {
        Enable-ComputerRestore -Drive "C:\"
        Write-Host "Success: System Restore enabled." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-Script
}

function Create-RestorePoint {
    Show-Header
    Write-Host "Creating a System Restore Point..." -ForegroundColor Yellow
    $desc = Read-Host "Enter a name for the restore point (default: Maintenance_Checkpoint)"
    if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "Maintenance_Checkpoint" }
    
    try {
        Checkpoint-Computer -Description $desc -RestorePointType "MODIFY_SETTINGS"
        Write-Host "Success: Restore point '$desc' created." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Could not create restore point. Ensure System Restore is enabled." -ForegroundColor Red
        Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-Script
}

function Run-SFC {
    Show-Header
    Write-Host "Running System File Checker (SFC)..." -ForegroundColor Yellow
    Write-Host "This may take some time." -ForegroundColor Gray
    sfc /scannow
    Pause-Script
}

function Run-DISM {
    Show-Header
    Write-Host "Running DISM Image Cleanup and Health Restore..." -ForegroundColor Yellow
    Write-Host "This checks for component store corruption and attempts to repair it." -ForegroundColor Gray
    DISM.exe /Online /Cleanup-image /Restorehealth
    Pause-Script
}

function Run-DiskCleanup {
    Show-Header
    Write-Host "Running Disk Cleanup Tool..." -ForegroundColor Yellow
    Write-Host "Opening standard Disk Cleanup dialog..." -ForegroundColor Gray
    # Using /lowdisk to launch the UI directly or /run for sagerun if preferred, 
    # but /sagerun needs previous /sageset configuration.
    # To be safe and interactive, we'll launch the cleanmgr selection.
    
    # Attempting to use a comprehensive set (needs registry preset usually, creating temp one)
    Start-Process cleanmgr.exe -Wait
    
    # Or purely automated (requires 'sageset' setup previously):
    # cleanmgr.exe /sagerun:1 
    
    Write-Host "Disk Cleanup finished." -ForegroundColor Green
    Pause-Script
}

function Run-Chkdsk {
    Show-Header
    Write-Host "Scheduling Disk Check (CHKDSK) for C: drive..." -ForegroundColor Yellow
    Write-Host "You will need to restart your computer for this to run." -ForegroundColor Gray
    
    $choice = Read-Host "Schedule CHKDSK on next restart? (Y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        # Piping 'y' to chkdsk to accept the schedule prompt
        echo y | chkdsk C: /f /r
        Write-Host "CHKDSK scheduled." -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
    }
    Pause-Script
}

function Clear-TempFiles {
    Show-Header
    Write-Host "Clearing Temporary Files..." -ForegroundColor Yellow
    
    $paths = @(
        "$env:TEMP\*",
        "$env:windir\Temp\*",
        "$env:windir\Prefetch\*"
    )

    foreach ($path in $paths) {
        Write-Host "Cleaning: $path" -ForegroundColor Gray
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Skipped some locked files in $path" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "Temporary files cleanup complete." -ForegroundColor Green
    Pause-Script
}

function Reset-WindowsStore {
    Show-Header
    Write-Host "Resetting Microsoft Store Cache (WSReset)..." -ForegroundColor Yellow
    Write-Host "This will open the Store app when finished." -ForegroundColor Gray
    Start-Process "wsreset.exe" -Wait
    Write-Host "Store reset complete." -ForegroundColor Green
    Pause-Script
}

function Optimize-Drives {
    Show-Header
    Write-Host "Optimizing Drives..." -ForegroundColor Yellow
    
    $drives = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' }
    foreach ($vol in $drives) {
        $driveLetter = $vol.DriveLetter
        if ($driveLetter) {
            Write-Host "Optimizing Drive $driveLetter..." -ForegroundColor Cyan
            try {
                Optimize-Volume -DriveLetter $driveLetter -ReTrim -Defrag -Verbose
            } catch {
                Write-Host "Error optimizing $driveLetter : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    Pause-Script
}

function Reset-Network {
    Show-Header
    Write-Host "Resetting Network Stack..." -ForegroundColor Yellow
    
    Write-Host "Flushing DNS..."
    ipconfig /flushdns
    
    Write-Host "Releasing IP..."
    ipconfig /release
    
    Write-Host "Renewing IP..."
    ipconfig /renew
    
    Write-Host "Resetting Winsock catalog..."
    netsh winsock reset
    
    Write-Host "Resetting IP TCP stack..."
    netsh int ip reset
    
    Write-Host "Network reset complete." -ForegroundColor Green
    Pause-Script
}

function Reset-WindowsUpdate {
    Show-Header
    Write-Host "Resetting Windows Update Components..." -ForegroundColor Yellow
    
    $services = "wuauserv", "cryptSvc", "bits", "msiserver"
    
    foreach ($service in $services) {
        Write-Host "Stopping $service..."
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Renaming SoftwareDistribution and Catroot2 folders..."
    if (Test-Path "$env:windir\SoftwareDistribution") {
        Rename-Item "$env:windir\SoftwareDistribution" "$env:windir\SoftwareDistribution.old" -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:windir\System32\catroot2") {
        Rename-Item "$env:windir\System32\catroot2" "$env:windir\System32\catroot2.old" -ErrorAction SilentlyContinue
    }
    
    foreach ($service in $services) {
        Write-Host "Starting $service..."
        Start-Service -Name $service -ErrorAction SilentlyContinue
    }
    
    Write-Host "Windows Update reset complete." -ForegroundColor Green
    Pause-Script
}

function Set-HighPerformance {
    Show-Header
    Write-Host "Setting Power Plan to High Performance..." -ForegroundColor Yellow
    # 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c is the GUID for High Performance
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    if ($LASTEXITCODE -eq 0) {
        Write-Host "High Performance plan activated." -ForegroundColor Green
    } else {
        # Fallback to schemes check if GUID is missing/custom
        Write-Host "Could not set by ID. Listing schemes:"
        powercfg -list
        Write-Host "Please manually select a scheme using 'powercfg -setactive <GUID>'"
    }
    Pause-Script
}

function Clear-EventLogs {
    Show-Header
    Write-Host "Clearing Windows Event Logs..." -ForegroundColor Yellow
    $logs = Get-EventLog -List
    foreach ($log in $logs) {
        try {
            Write-Host "Clearing $($log.Log)..." -NoNewline
            Clear-EventLog -LogName $log.Log -ErrorAction Stop
            Write-Host " Done." -ForegroundColor Green
        } catch {
            Write-Host " Failed (Access/InUse)." -ForegroundColor Red
        }
    }
    Pause-Script
}

function Run-CommonMaintenance {
    Show-Header
    Write-Host "Starting Common Maintenance Routine..." -ForegroundColor Magenta
    Start-Sleep -Seconds 2
    
    Enable-SystemRestore
    
    # Non-interactive restoration point
    Checkpoint-Computer -Description "AutoMaintenance" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    
    # Run safe cleanup
    $paths = @("$env:TEMP\*", "$env:windir\Temp\*")
    foreach ($path in $paths) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }
    
    # SFC
    Write-Host "Running SFC (Quick mode check not possible, running full)..."
    sfc /scannow
    
    # DISM
    DISM.exe /Online /Cleanup-image /Restorehealth
    
    Write-Host "Routine complete." -ForegroundColor Green
    Pause-Script
}

# ---------------------------------------------------------------------------
# Main Menu Loop
# ---------------------------------------------------------------------------

do {
    Show-Header
    Write-Host "1.  Create Restore Point"
    Write-Host "2.  Run System File Checker (SFC)"
    Write-Host "3.  Run DISM Image Repair"
    Write-Host "4.  Clear Temporary Files"
    Write-Host "5.  Disk Cleanup"
    Write-Host "6.  Check Disk (Schedule for Restart)"
    Write-Host "7.  Reset Windows Store"
    Write-Host "8.  Optimize/Defrag Drives"
    Write-Host "9.  Network Reset (Flush DNS/IP)"
    Write-Host "10. Reset Windows Update Components"
    Write-Host "11. Set High Performance Power Plan"
    Write-Host "12. Clear Event Logs"
    Write-Host "----------------------------------" -ForegroundColor Gray
    Write-Host "A.  Run All Common Tasks (SFC, DISM, Temp)" -ForegroundColor Cyan
    Write-Host "Q.  Quit"
    Write-Host "============================================================" -ForegroundColor Cyan
    
    $selection = Read-Host "Select an option"
    
    switch ($selection) {
        '1' { Create-RestorePoint }
        '2' { Run-SFC }
        '3' { Run-DISM }
        '4' { Clear-TempFiles }
        '5' { Run-DiskCleanup }
        '6' { Run-Chkdsk }
        '7' { Reset-WindowsStore }
        '8' { Optimize-Drives }
        '9' { Reset-Network }
        '10' { Reset-WindowsUpdate }
        '11' { Set-HighPerformance }
        '12' { Clear-EventLogs }
        {$_ -eq 'a' -or $_ -eq 'A'} { Run-CommonMaintenance }
        {$_ -eq 'q' -or $_ -eq 'Q'} { return }
        Default { Write-Warning "Invalid selection. Please try again."; Start-Sleep -Seconds 1 }
    }
} until ($selection -eq 'q' -or $selection -eq 'Q')
