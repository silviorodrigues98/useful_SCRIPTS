<#
.SYNOPSIS
    CUPS Printer Manager for Windows
    
.DESCRIPTION
    A GUI tool to fetch printers from a CUPS server web interface, 
    install them on Windows using a specific driver, and manage 
    (remove) existing printers and their associated HTTP/IPP ports.

.NOTES
    Author: [Your Name/GitHub Username]
    License: MIT
#>

# ==============================================================================
# USER CONFIGURATION (EDIT THIS SECTION)
# ==============================================================================
# The URL of your CUPS printers page (e.g., http://192.168.1.10:631/printers)
$CupsUrl = "http://your-cups-server:631/printers" 

# The EXACT name of the driver installed on Windows to use (e.g., "Generic / Text Only", "MS Publisher Imagesetter")
$DriverName = "Generic / Text Only"

# A unique string part of your server URL to identify ports in the Registry to be cleaned
# Example: If your URL is http://print-server:631, use "print-server"
$PortIdentifierString = "your-cups-server" 

# ==============================================================================
# ADMIN CHECK & AUTO-ELEVATION
# ==============================================================================
$currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $currentUser.IsInRole($adminRole)) {
    Write-Warning "This script requires Administrator privileges. Attempting to elevate..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    exit
}

# Load GUI Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================================================================
# HELPER FUNCTION: GHOST PORT CLEANUP (REGISTRY)
# ==============================================================================
function Clean-GhostPorts {
    Write-Host "`n--- STARTING PORT CLEANUP ---" -ForegroundColor Cyan
    
    # 1. Identify ports currently in use (to avoid deleting active ones)
    $activePorts = @(Get-Printer | Select-Object -ExpandProperty PortName -ErrorAction SilentlyContinue)
    
    # 2. Stop Spooler to unlock registry keys
    Write-Host "Stopping Spooler service..." -ForegroundColor Yellow
    Stop-Service Spooler -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # 3. Registry Path for Internet Ports (HTTP/IPP)
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\Internet Print Provider\Ports"

    if (Test-Path $regPath) {
        # Find ports matching our server identifier
        $registryPorts = Get-ChildItem -Path $regPath | Where-Object { $_.Name -like "*$PortIdentifierString*" }
        
        foreach ($regKey in $registryPorts) {
            $portNameInRegistry = $regKey.PSChildName 
            
            # If the port in registry is NOT in the active ports list -> DELETE IT
            if ($portNameInRegistry -notin $activePorts) {
                try {
                    Remove-Item -Path $regKey.PSPath -Recurse -Force -ErrorAction Stop
                    Write-Host "Ghost port removed: $portNameInRegistry" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to remove registry key: $portNameInRegistry"
                }
            } else {
                Write-Host "Keeping active port: $portNameInRegistry" -ForegroundColor Gray
            }
        }
    }

    # 4. Restart Spooler
    Write-Host "Restarting Spooler..." -ForegroundColor Yellow
    Start-Service Spooler
    Write-Host "Cleanup finished." -ForegroundColor Cyan
}

# ==============================================================================
# MENU 1: INSTALL PRINTERS (FROM CUPS)
# ==============================================================================
function Show-InstallMenu {
    $formInst = New-Object System.Windows.Forms.Form
    $formInst.Text = "Install Printers (CUPS)"
    $formInst.Size = New-Object System.Drawing.Size(400, 600)
    $formInst.StartPosition = "CenterScreen"
    $formInst.MinimizeBox = $false
    $formInst.MaximizeBox = $false
    
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Fetching printer list..."
    $lbl.AutoSize = $true
    $lbl.Location = New-Object System.Drawing.Point(10,10)
    $formInst.Controls.Add($lbl)

    $chkList = New-Object System.Windows.Forms.CheckedListBox
    $chkList.Location = New-Object System.Drawing.Point(10, 40)
    $chkList.Size = New-Object System.Drawing.Size(365, 450)
    $chkList.CheckOnClick = $true
    $formInst.Controls.Add($chkList)

    # Back Button
    $btnBack = New-Object System.Windows.Forms.Button
    $btnBack.Text = "Back"
    $btnBack.Location = New-Object System.Drawing.Point(10, 500)
    $btnBack.Size = New-Object System.Drawing.Size(100, 40)
    $btnBack.Add_Click({ $formInst.Close() })
    $formInst.Controls.Add($btnBack)

    # Install Button
    $btnInst = New-Object System.Windows.Forms.Button
    $btnInst.Text = "INSTALL SELECTED"
    $btnInst.Location = New-Object System.Drawing.Point(120, 500)
    $btnInst.Size = New-Object System.Drawing.Size(255, 40)
    $btnInst.BackColor = "LightGreen"
    
    # Fetch Logic
    try {
        $formInst.Refresh()
        $response = Invoke-WebRequest -Uri $CupsUrl -UseBasicParsing -ErrorAction Stop
        
        # Decode UTF8
        if ($response.Content -is [byte[]]) { $html = [System.Text.Encoding]::UTF8.GetString($response.Content) } 
        else { $html = $response.Content }
        
        $cleanHtml = $html -replace "`r", "" -replace "`n", ""
        
        # Regex to find CUPS links: href="/printers/QUEUE_NAME"
        $pattern = '(?i)<a\s+href="/printers/([^"]+)">'
        $printerList = [regex]::Matches($cleanHtml, $pattern) | ForEach-Object { $_.Groups[1].Value.Trim() } | Select-Object -Unique | Sort-Object
        
        foreach ($p in $printerList) { [void]$chkList.Items.Add($p) }
        $lbl.Text = "Select printers to INSTALL:"
    } catch {
        $lbl.Text = "Error connecting to CUPS server."
        $lbl.ForeColor = "Red"
    }
    
    $btnInst.Add_Click({
        $sel = $chkList.CheckedItems
        if ($sel.Count -eq 0) { return }
        
        $confirm = [System.Windows.Forms.MessageBox]::Show("Install $($sel.Count) printers?", "Confirm", 4, 32)
        if ($confirm -eq "Yes") {
            $formInst.Hide()
            foreach ($name in $sel) {
                # Construct the full URL based on the base URL provided in config
                # Assumes CUPS URL format: base_url/printer_name
                $serverPath = "$CupsUrl/$name"
                
                # Windows Driver path
                $inf = "$env:windir\inf\ntprint.inf"
                
                # Command execution
                $arguments = "printui.dll,PrintUIEntry /if /b ""$name"" /f ""$inf"" /r ""$serverPath"" /m ""$DriverName"""
                Start-Process "rundll32.exe" -ArgumentList $arguments -Wait
            }
            [System.Windows.Forms.MessageBox]::Show("Installation Finished!", "Success")
            $formInst.Close()
        }
    })
    $formInst.Controls.Add($btnInst)
    
    [void]$formInst.ShowDialog()
}

# ==============================================================================
# MENU 2: UNINSTALL PRINTERS (LOCAL)
# ==============================================================================
function Show-UninstallMenu {
    $formRem = New-Object System.Windows.Forms.Form
    $formRem.Text = "Uninstall Printers"
    $formRem.Size = New-Object System.Drawing.Size(400, 600)
    $formRem.StartPosition = "CenterScreen"
    $formRem.MinimizeBox = $false
    $formRem.MaximizeBox = $false

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Select printers to REMOVE:"
    $lbl.AutoSize = $true
    $lbl.Location = New-Object System.Drawing.Point(10,10)
    $formRem.Controls.Add($lbl)

    $chkList = New-Object System.Windows.Forms.CheckedListBox
    $chkList.Location = New-Object System.Drawing.Point(10, 40)
    $chkList.Size = New-Object System.Drawing.Size(365, 450)
    $chkList.CheckOnClick = $true
    $formRem.Controls.Add($chkList)

    try {
        $localPrinters = Get-Printer | Sort-Object Name
        foreach ($p in $localPrinters) { [void]$chkList.Items.Add($p.Name) }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error listing local printers.", "Error")
    }

    # Back Button
    $btnBack = New-Object System.Windows.Forms.Button
    $btnBack.Text = "Back"
    $btnBack.Location = New-Object System.Drawing.Point(10, 500)
    $btnBack.Size = New-Object System.Drawing.Size(100, 40)
    $btnBack.Add_Click({ $formRem.Close() })
    $formRem.Controls.Add($btnBack)

    # Uninstall Button
    $btnRem = New-Object System.Windows.Forms.Button
    $btnRem.Text = "REMOVE SELECTED"
    $btnRem.Location = New-Object System.Drawing.Point(120, 500)
    $btnRem.Size = New-Object System.Drawing.Size(255, 40)
    $btnRem.BackColor = "Salmon"

    $btnRem.Add_Click({
        $sel = $chkList.CheckedItems
        if ($sel.Count -eq 0) { return }

        $confirm = [System.Windows.Forms.MessageBox]::Show("Remove $($sel.Count) printers? This will also clean registry ports.", "Warning", 4, 48)
        if ($confirm -eq "Yes") {
            $formRem.Hide()
            
            # 1. Standard Removal
            foreach ($name in $sel) {
                try {
                    Remove-Printer -Name $name -ErrorAction Stop
                    Write-Host "Removed: $name" -ForegroundColor Yellow
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Error removing $($name): $_", "Error")
                }
            }

            # 2. Deep Clean (Ghost Ports)
            Clean-GhostPorts

            [System.Windows.Forms.MessageBox]::Show("Removal and Cleanup Finished!", "Success")
            $formRem.Close()
        }
    })
    $formRem.Controls.Add($btnRem)
    
    [void]$formRem.ShowDialog()
}

# ==============================================================================
# MAIN MENU LOOP
# ==============================================================================
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Printer Manager"
$mainForm.Size = New-Object System.Drawing.Size(350, 260)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedDialog"
$mainForm.MaximizeBox = $false

$lblMain = New-Object System.Windows.Forms.Label
$lblMain.Text = "Select an option:"
$lblMain.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$lblMain.AutoSize = $true
$lblMain.Location = New-Object System.Drawing.Point(90, 20)
$mainForm.Controls.Add($lblMain)

# Button: Install
$btnGoInstall = New-Object System.Windows.Forms.Button
$btnGoInstall.Text = "INSTALL (From CUPS)"
$btnGoInstall.Location = New-Object System.Drawing.Point(20, 60)
$btnGoInstall.Size = New-Object System.Drawing.Size(140, 60)
$btnGoInstall.BackColor = "LightGreen"
$btnGoInstall.Add_Click({ 
    $mainForm.Hide()
    Show-InstallMenu 
    $mainForm.Show() 
})
$mainForm.Controls.Add($btnGoInstall)

# Button: Uninstall
$btnGoUninstall = New-Object System.Windows.Forms.Button
$btnGoUninstall.Text = "UNINSTALL (Local)"
$btnGoUninstall.Location = New-Object System.Drawing.Point(170, 60)
$btnGoUninstall.Size = New-Object System.Drawing.Size(140, 60)
$btnGoUninstall.BackColor = "Salmon"
$btnGoUninstall.Add_Click({ 
    $mainForm.Hide()
    Show-UninstallMenu 
    $mainForm.Show() 
})
$mainForm.Controls.Add($btnGoUninstall)

# Button: Exit
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "EXIT"
$btnExit.Location = New-Object System.Drawing.Point(20, 140)
$btnExit.Size = New-Object System.Drawing.Size(290, 40)
$btnExit.Add_Click({ 
    $mainForm.Close() 
})
$mainForm.Controls.Add($btnExit)

# Start GUI
[void]$mainForm.ShowDialog()