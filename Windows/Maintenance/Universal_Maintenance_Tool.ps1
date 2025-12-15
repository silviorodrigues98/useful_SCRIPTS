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
# Localization Dictionary
# ---------------------------------------------------------------------------
$Dict = @{
    EN = @{
        HeaderTitle      = "           WINDOWS UNIVERSAL MAINTENANCE TOOL               "
        PauseMsg         = "Press any key to return to the menu..."
        
        EnableRestore    = "Enabling System Restore on C: drive..."
        ResPointSuccess  = "Success: Restore point created."
        ResPointFail     = "Error: Could not create restore point."
        
        SFCStart         = "Running System File Checker (SFC)..."
        SFCNote          = "This may take some time."
        
        DISMStart        = "Running DISM Image Cleanup and Health Restore..."
        DISMNote         = "This checks for component store corruption and attempts to repair it."
        
        DiskCleanStart   = "Running Disk Cleanup Tool..."
        DiskCleanMsg     = "Opening standard Disk Cleanup dialog..."
        DiskCleanDone    = "Disk Cleanup finished."
        
        ChkdskAsk        = "Schedule CHKDSK on next restart? (Y/N)"
        ChkdskScheduled  = "CHKDSK scheduled."
        ChkdskCancelled  = "Operation cancelled."
        
        ClearTempStart   = "Clearing Temporary Files..."
        ClearTempDone    = "Temporary files cleanup complete."
        Cleaning         = "Cleaning:"
        
        StoreReset       = "Resetting Microsoft Store Cache (WSReset)..."
        StoreDone        = "Store reset complete."
        
        OptStart         = "Optimizing Drives..."
        OptDrive         = "Optimizing Drive"
        
        NetReset         = "Resetting Network Stack..."
        NetFlush         = "Flushing DNS..."
        NetRelease       = "Releasing IP..."
        NetRenew         = "Renewing IP..."
        NetWinsock       = "Resetting Winsock catalog..."
        NetIP            = "Resetting IP TCP stack..."
        NetDone          = "Network reset complete."
        
        UpdateReset      = "Resetting Windows Update Components..."
        Stopping         = "Stopping"
        Starting         = "Starting"
        Renaming         = "Renaming SoftwareDistribution and Catroot2 folders..."
        UpdateDone       = "Windows Update reset complete."
        
        PowerHigh        = "Setting Power Plan to High Performance..."
        PowerDone        = "High Performance plan activated."
        PowerFail        = "Could not set by ID. Please disable manually."
        
        EventLogStart    = "Clearing Windows Event Logs..."
        EventLogDone     = "Done."
        
        RoutineStart     = "Starting Common Maintenance Routine..."
        RoutineDone      = "Routine complete."
        
        SelectOption     = "Select an option"
        InvalidSel       = "Invalid selection. Please try again."
        
        Menu_1           = "1.  Create Restore Point"
        Menu_2           = "2.  Run System File Checker (SFC)"
        Menu_3           = "3.  Run DISM Image Repair"
        Menu_4           = "4.  Clear Temporary Files"
        Menu_5           = "5.  Disk Cleanup"
        Menu_6           = "6.  Check Disk (Schedule on Restart)"
        Menu_7           = "7.  Reset Windows Store"
        Menu_8           = "8.  Optimize/Defrag Drives"
        Menu_9           = "9.  Network Reset (Flush DNS/IP)"
        Menu_10          = "10. Reset Windows Update Components"
        Menu_11          = "11. Set High Performance Power Plan"
        Menu_12          = "12. Clear Event Logs"
        Menu_A           = "A.  Run All Common Tasks (SFC, DISM, Temp)"
        Menu_Q           = "Q.  Quit"
        
        StartupTitle     = "Startup Applications Manager"
        ServicesTitle    = "Services Manager"
        Menu_13          = "13. Manage Startup Apps"
        Menu_14          = "14. Manage Services"
        StartupList      = "Listing Startup Applications..."
        StartupRemove    = "Enter ID to Toggle/Remove (or 'q' to go back): "
        StartupRemoved   = "Startup item Removed."
        StartupToggled   = "Startup item Toggled."
        StartupNotFound  = "Item not found."
        StartupEnabled   = "Enabled"
        StartupDisabled  = "Disabled"
        StartupAction    = "Select Action: 1. Toggle Status (Enable/Disable) 2. Remove Permanently"
        ServiceList      = "Listing Services..."
        ServiceSearch    = "Search filter (leave empty for all): "
        ServiceAction    = "Enter Service Name to manage (or 'q' to go back): "
        ServiceOpt       = "1. Start 2. Stop 3. Restart 4. Set Startup Type"
        ServiceStart     = "Starting service..."
        ServiceStop      = "Stopping service..."
        ServiceRestart   = "Restarting service..."
        ServiceType      = "Select Startup Type: 1. Automatic 2. Manual 3. Disabled"
        ServiceSuccess   = "Operation successful."
    }
    
    PT = @{
        HeaderTitle      = "      FERRAMENTA UNIVERSAL DE MANUTENCAO WINDOWS            "
        PauseMsg         = "Pressione qualquer tecla para voltar ao menu..."
        
        EnableRestore    = "Habilitando Restauracao do Sistema no drive C:..."
        ResPointSuccess  = "Sucesso: Ponto de restauracao criado."
        ResPointFail     = "Erro: Nao foi possivel criar o ponto de restauracao."
        
        SFCStart         = "Executando Verificador de Arquivos do Sistema (SFC)..."
        SFCNote          = "Isso pode levar algum tempo."
        
        DISMStart        = "Executando DISM (Reparo de Imagem)..."
        DISMNote         = "Isso verifica a corrupcao do armazenamento de componentes e tenta repara-lo."
        
        DiskCleanStart   = "Executando Limpeza de Disco..."
        DiskCleanMsg     = "Abrindo dialogo padrao de Limpeza de Disco..."
        DiskCleanDone    = "Limpeza de Disco concluida."
        
        ChkdskAsk        = "Agendar CHKDSK para a proxima reinicializacao? (S/N)"
        ChkdskScheduled  = "CHKDSK agendado."
        ChkdskCancelled  = "Operacao cancelada."
        
        ClearTempStart   = "Limpando Arquivos Temporarios..."
        ClearTempDone    = "Limpeza de arquivos temporarios concluida."
        Cleaning         = "Limpando:"
        
        StoreReset       = "Redefinindo Cache da Microsoft Store (WSReset)..."
        StoreDone        = "Redefinicao da Store concluida."
        
        OptStart         = "Otimizando Unidades..."
        OptDrive         = "Otimizando Drive"
        
        NetReset         = "Redefinindo Pilha de Rede..."
        NetFlush         = "Limpando cache DNS..."
        NetRelease       = "Liberando IP..."
        NetRenew         = "Renovando IP..."
        NetWinsock       = "Redefinindo catalogo Winsock..."
        NetIP            = "Redefinindo pilha TCP IP..."
        NetDone          = "Redefinicao de rede concluida."
        
        UpdateReset      = "Redefinindo Componentes do Windows Update..."
        Stopping         = "Parando"
        Starting         = "Iniciando"
        Renaming         = "Renomeando pastas SoftwareDistribution e Catroot2..."
        UpdateDone       = "Redefinicao do Windows Update concluida."
        
        PowerHigh        = "Definindo Plano de Energia para Alto Desempenho..."
        PowerDone        = "Plano de Alto Desempenho ativado."
        PowerFail        = "Nao foi possivel definir pelo ID."
        
        EventLogStart    = "Limpando Logs de Eventos do Windows..."
        EventLogDone     = "Feito."
        
        RoutineStart     = "Iniciando Rotina de Manutencao Comum..."
        RoutineDone      = "Rotina completa."
        
        SelectOption     = "Selecione uma opcao"
        InvalidSel       = "Selecao invalida. Tente novamente."
        
        Menu_1           = "1.  Criar Ponto de Restauracao"
        Menu_2           = "2.  Executar SFC (Verificador de Arquivos)"
        Menu_3           = "3.  Executar DISM (Reparo de Imagem)"
        Menu_4           = "4.  Limpar Arquivos Temporarios"
        Menu_5           = "5.  Limpeza de Disco"
        Menu_6           = "6.  Verificar Disco (Agendar no Reinicio)"
        Menu_7           = "7.  Redefinir Windows Store"
        Menu_8           = "8.  Otimizar/Desfragmentar Drives"
        Menu_9           = "9.  Redefinir Rede (Flush DNS/IP)"
        Menu_10          = "10. Redefinir Windows Update"
        Menu_11          = "11. Definir Alto Desempenho"
        Menu_12          = "12. Limpar Logs de Eventos"
        Menu_A           = "A.  Executar Tarefas Comuns (SFC, DISM, Temp)"
        Menu_Q           = "Q.  Sair"

        StartupTitle     = "Gerenciador de Aplicativos de Inicializacao"
        ServicesTitle    = "Gerenciador de Servicos"
        Menu_13          = "13. Gerenciar Apps de Inicializacao"
        Menu_14          = "14. Gerenciar Servicos"
        StartupList      = "Listando Aplicativos de Inicializacao..."
        StartupRemove    = "Digite o ID para Alterar/Remover (ou 'q' para voltar): "
        StartupRemoved   = "Item de inicializacao removido."
        StartupToggled   = "Status do item alterado."
        StartupNotFound  = "Item nao encontrado."
        StartupEnabled   = "Habilitado"
        StartupDisabled  = "Desabilitado"
        StartupAction    = "Selecione Acao: 1. Alternar Status (Ativar/Desativar) 2. Remover Permanentemente"
        ServiceList      = "Listando Servicos..."
        ServiceSearch    = "Filtro de busca (vazio para todos): "
        ServiceAction    = "Nome do Servico para gerenciar (ou 'q' para voltar): "
        ServiceOpt       = "1. Iniciar 2. Parar 3. Reiniciar 4. Tipo de Inicializacao"
        ServiceStart     = "Iniciando servico..."
        ServiceStop      = "Parando servico..."
        ServiceRestart   = "Reiniciando servico..."
        ServiceType      = "Selecione Tipo: 1. Automatico 2. Manual 3. Desativado"
        ServiceSuccess   = "Operacao realizada com sucesso."
    }
}

# ---------------------------------------------------------------------------
# Language Selection
# ---------------------------------------------------------------------------
Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "           WINDOWS UNIVERSAL MAINTENANCE TOOL               " -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose your language / Escolha seu idioma:" 
Write-Host "1. English"
Write-Host "2. Portugues"
Write-Host ""
$langChoice = Read-Host "Select/Selecione (1/2)"

if ($langChoice -eq '2') {
    $L = $Dict.PT
} else {
    $L = $Dict.EN
}

# ---------------------------------------------------------------------------
# Helper Functions using Localization
# ---------------------------------------------------------------------------

function Show-Header {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $L.HeaderTitle -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Script {
    Write-Host ""
    Write-Host $L.PauseMsg -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ---------------------------------------------------------------------------
# Core Functions
# ---------------------------------------------------------------------------

function Enable-SystemRestore {
    Show-Header
    Write-Host $L.EnableRestore -ForegroundColor Yellow
    try {
        Enable-ComputerRestore -Drive "C:\"
        Write-Host "OK" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-Script
}

function Create-RestorePoint {
    Show-Header
    Write-Host $L.EnableRestore -ForegroundColor Yellow # Re-using string for context
    
    # Auto-naming for simplicity or prompt if needed. Let's automate for smoother UX.
    $desc = "Maintenance_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    
    try {
        Checkpoint-Computer -Description $desc -RestorePointType "MODIFY_SETTINGS"
        Write-Host "$($L.ResPointSuccess) ($desc)" -ForegroundColor Green
    }
    catch {
        Write-Host $L.ResPointFail -ForegroundColor Red
        Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-Script
}

function Run-SFC {
    Show-Header
    Write-Host $L.SFCStart -ForegroundColor Yellow
    Write-Host $L.SFCNote -ForegroundColor Gray
    sfc /scannow
    Pause-Script
}

function Run-DISM {
    Show-Header
    Write-Host $L.DISMStart -ForegroundColor Yellow
    Write-Host $L.DISMNote -ForegroundColor Gray
    DISM.exe /Online /Cleanup-image /Restorehealth
    Pause-Script
}

function Run-DiskCleanup {
    Show-Header
    Write-Host $L.DiskCleanStart -ForegroundColor Yellow
    Write-Host $L.DiskCleanMsg -ForegroundColor Gray
    Start-Process cleanmgr.exe -Wait
    Write-Host $L.DiskCleanDone -ForegroundColor Green
    Pause-Script
}

function Run-Chkdsk {
    Show-Header
    Write-Host $L.ChkdskAsk -ForegroundColor Yellow
    
    $choice = Read-Host "?"
    if ($choice -match '^[yYsS]') { # Matches Y or S (Sim)
        echo y | chkdsk C: /f /r
        Write-Host $L.ChkdskScheduled -ForegroundColor Green
    } else {
        Write-Host $L.ChkdskCancelled -ForegroundColor Yellow
    }
    Pause-Script
}

function Clear-TempFiles {
    Show-Header
    Write-Host $L.ClearTempStart -ForegroundColor Yellow
    
    $paths = @(
        "$env:TEMP\*",
        "$env:windir\Temp\*",
        "$env:windir\Prefetch\*"
    )

    foreach ($path in $paths) {
        Write-Host "$($L.Cleaning) $path" -ForegroundColor Gray
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        } catch { }
    }
    
    Write-Host $L.ClearTempDone -ForegroundColor Green
    Pause-Script
}

function Reset-WindowsStore {
    Show-Header
    Write-Host $L.StoreReset -ForegroundColor Yellow
    Start-Process "wsreset.exe" -Wait
    Write-Host $L.StoreDone -ForegroundColor Green
    Pause-Script
}

function Optimize-Drives {
    Show-Header
    Write-Host $L.OptStart -ForegroundColor Yellow
    
    $drives = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' }
    foreach ($vol in $drives) {
        $driveLetter = $vol.DriveLetter
        if ($driveLetter) {
            Write-Host "$($L.OptDrive) $driveLetter..." -ForegroundColor Cyan
            try {
                Optimize-Volume -DriveLetter $driveLetter -ReTrim -Defrag -Verbose
            } catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    Pause-Script
}

function Reset-Network {
    Show-Header
    Write-Host $L.NetReset -ForegroundColor Yellow
    
    Write-Host $L.NetFlush; ipconfig /flushdns
    Write-Host $L.NetRelease; ipconfig /release
    Write-Host $L.NetRenew; ipconfig /renew
    Write-Host $L.NetWinsock; netsh winsock reset
    Write-Host $L.NetIP; netsh int ip reset
    
    Write-Host $L.NetDone -ForegroundColor Green
    Pause-Script
}

function Reset-WindowsUpdate {
    Show-Header
    Write-Host $L.UpdateReset -ForegroundColor Yellow
    
    $services = "wuauserv", "cryptSvc", "bits", "msiserver"
    
    foreach ($service in $services) {
        Write-Host "$($L.Stopping) $service..."
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host $L.Renaming
    if (Test-Path "$env:windir\SoftwareDistribution") {
        Rename-Item "$env:windir\SoftwareDistribution" "$env:windir\SoftwareDistribution.old" -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:windir\System32\catroot2") {
        Rename-Item "$env:windir\System32\catroot2" "$env:windir\System32\catroot2.old" -ErrorAction SilentlyContinue
    }
    
    foreach ($service in $services) {
        Write-Host "$($L.Starting) $service..."
        Start-Service -Name $service -ErrorAction SilentlyContinue
    }
    
    Write-Host $L.UpdateDone -ForegroundColor Green
    Pause-Script
}

function Set-HighPerformance {
    Show-Header
    Write-Host $L.PowerHigh -ForegroundColor Yellow
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    if ($LASTEXITCODE -eq 0) {
        Write-Host $L.PowerDone -ForegroundColor Green
    } else {
        Write-Host $L.PowerFail
    }
    Pause-Script
}

function Clear-EventLogs {
    Show-Header
    Write-Host $L.EventLogStart -ForegroundColor Yellow
    $logs = Get-EventLog -List
    foreach ($log in $logs) {
        try {
            Write-Host "$($L.Cleaning) $($log.Log)..." -NoNewline
            Clear-EventLog -LogName $log.Log -ErrorAction Stop
            Write-Host " " + $L.EventLogDone -ForegroundColor Green
        } catch { }
    }
    Pause-Script
}

function Run-CommonMaintenance {
    Show-Header
    Write-Host $L.RoutineStart -ForegroundColor Magenta
    Start-Sleep -Seconds 2
    
    # Silent/Auto operations where possible
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "AutoMaintenance" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    
    $paths = @("$env:TEMP\*", "$env:windir\Temp\*")
    foreach ($path in $paths) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }
    
    Write-Host "SFC..."
    sfc /scannow
    
    Write-Host "DISM..."
    DISM.exe /Online /Cleanup-image /Restorehealth
    
    Write-Host $L.RoutineDone -ForegroundColor Green
    Pause-Script
}

# ---------------------------------------------------------------------------
# Extended Functions - Startup Manager
# ---------------------------------------------------------------------------

function Get-StartupApps {
    $apps = @()
    
    # Registry Keys (Run and Run_Disabled)
    $regKeys = @(
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"; Root = "HKCU"; Status = $L.StartupEnabled },
        @{ Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"; Root = "HKLM"; Status = $L.StartupEnabled },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run_Disabled"; Root = "HKCU"; Status = $L.StartupDisabled },
        @{ Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run_Disabled"; Root = "HKLM"; Status = $L.StartupDisabled }
    )

    foreach ($key in $regKeys) {
        if (Test-Path $key.Path) {
            $items = Get-ItemProperty -Path $key.Path
            foreach ($name in $items.PSObject.Properties.Name) {
                if ($name -match '^(PSPath|PSParentPath|PSChildName|PSDrive|PSProvider)$') { continue }
                $apps += [PSCustomObject]@{
                    Name = $name
                    Command = $items.$name
                    Location = $key.Path
                    Type = "Registry ($($key.Root))"
                    Status = $key.Status
                }
            }
        }
    }

    # Startup Folders
    $folders = @(
        @{ Path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"; Type = "User Startup Folder" },
        @{ Path = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"; Type = "System Startup Folder" }
    )

    foreach ($folder in $folders) {
        if (Test-Path $folder.Path) {
            # Standard Files
            $files = Get-ChildItem -Path $folder.Path -File | Where-Object { $_.Extension -ne ".disabled" }
            foreach ($file in $files) {
                $apps += [PSCustomObject]@{
                    Name = $file.Name
                    Command = $file.FullName
                    Location = $folder.Path
                    Type = $folder.Type
                    Status = $L.StartupEnabled
                }
            }
            # Disabled Files (We assume .disabled extension)
            $disabledFiles = Get-ChildItem -Path $folder.Path -File | Where-Object { $_.Extension -eq ".disabled" }
            foreach ($file in $disabledFiles) {
                $apps += [PSCustomObject]@{
                    Name = $file.Name.Replace(".disabled", "") # Display name without .disabled
                    Command = $file.FullName
                    Location = $folder.Path
                    Type = $folder.Type
                    Status = $L.StartupDisabled
                }
            }
        }
    }
    
    return $apps
}

function Manage-StartupApps {
    do {
        Show-Header
        Write-Host $L.StartupTitle -ForegroundColor Cyan
        Write-Host "----------------------------------" -ForegroundColor Gray
        
        $apps = Get-StartupApps
        
        if ($apps.Count -eq 0) {
            Write-Host "No startup apps found." -ForegroundColor Yellow
        } else {
            $i = 1
            $table = @()
            foreach ($app in $apps) {
                # ASCII Checkbox logic
                $state = "[ ]"
                if ($app.Status -eq $L.StartupEnabled) { $state = "[x]" }
                
                $table += [PSCustomObject]@{
                    ID = $i
                    State = $state
                    Name = $app.Name
                    Type = $app.Type
                    Command = $app.Command
                }
                $i++
            }
            $table | Format-Table -AutoSize
            Write-Host " [x] = $($L.StartupEnabled) | [ ] = $($L.StartupDisabled)" -ForegroundColor Gray
        }
        
        Write-Host ""
        # Update Prompt to indicate toggle capability
        Write-Host "Enter ID(s) to Toggle (e.g. 1,3,5) or 'r' plus ID to Remove (e.g. r1): " -NoNewline
        $choice = Read-Host
        
        if ($choice -match '^[qQ]$') { return }
        
        # Parse Input
        $ids = $choice -split ',' | ForEach-Object { $_.Trim() }
        
        foreach ($idStr in $ids) {
            if ($idStr -match '^r(\d+)$') {
                # Remove Logic
                $id = $matches[1]
                if ([int]$id -le $apps.Count -and [int]$id -gt 0) {
                    $selected = $apps[[int]$id - 1]
                    Write-Host "Removing $($selected.Name)..." -ForegroundColor Yellow
                    try {
                        if ($selected.Type -like "Registry*") {
                            Remove-ItemProperty -Path $selected.Location -Name $selected.Name -ErrorAction Stop
                        } else {
                            Remove-Item -Path $selected.Command -Force -ErrorAction Stop
                        }
                        Write-Host "$($selected.Name): $($L.StartupRemoved)" -ForegroundColor Green
                    } catch {
                        Write-Host "Error removing $($selected.Name): $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
            elseif ($idStr -match '^\d+$') {
                # Toggle Logic
                $id = $idStr
                if ([int]$id -le $apps.Count -and [int]$id -gt 0) {
                    $selected = $apps[[int]$id - 1]
                    try {
                         if ($selected.Type -like "Registry*") {
                            if ($selected.Status -eq $L.StartupEnabled) {
                                # Disable
                                $targetPath = $selected.Location.Replace("CurrentVersion\Run", "CurrentVersion\Run_Disabled")
                                if (!(Test-Path $targetPath)) { New-Item -Path $targetPath -Force | Out-Null }
                                Set-ItemProperty -Path $targetPath -Name $selected.Name -Value $selected.Command
                                Remove-ItemProperty -Path $selected.Location -Name $selected.Name
                            } else {
                                # Enable
                                $targetPath = $selected.Location.Replace("CurrentVersion\Run_Disabled", "CurrentVersion\Run")
                                Set-ItemProperty -Path $targetPath -Name $selected.Name -Value $selected.Command
                                Remove-ItemProperty -Path $selected.Location -Name $selected.Name
                            }
                        } else {
                            # Folder Items
                            if ($selected.Status -eq $L.StartupEnabled) {
                                # Disable
                                Rename-Item -Path $selected.Command -NewName "$($selected.Name).disabled"
                            } else {
                                # Enable
                                Rename-Item -Path $selected.Command -NewName ($selected.Command -replace '\.disabled$', '')
                            }
                        }
                        Write-Host "$($selected.Name): $($L.StartupToggled)" -ForegroundColor Green
                    } catch {
                         Write-Host "Error toggling $($selected.Name): $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        }
        Start-Sleep -Seconds 1
        
    } until ($false) # Infinite loop until 'q' returns
}

function Manage-Services {
    do {
        Show-Header
        Write-Host $L.ServicesTitle -ForegroundColor Cyan
        Write-Host "----------------------------------" -ForegroundColor Gray
        
        $filter = Read-Host $L.ServiceSearch
        if ([string]::IsNullOrWhiteSpace($filter)) {
            Write-Host $L.ServiceList -ForegroundColor Gray
            $services = Get-Service | Select-Object -First 50
        } else {
            $services = Get-Service | Where-Object { $_.Name -like "*$filter*" -or $_.DisplayName -like "*$filter*" }
        }
        
        if ($services.Count -eq 0) {
            Write-Host "No services found." -ForegroundColor Yellow
        } else {
            $services | Select-Object Status, Name, DisplayName, StartType | Format-Table -AutoSize
        }
        
        Write-Host ""
        $svcName = Read-Host $L.ServiceAction
        
        if ($svcName -notin 'q','Q') {
            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if ($svc) {
                 Write-Host "Selected: $($svc.Name) ($($svc.Status))" -ForegroundColor Cyan
                 Write-Host $L.ServiceOpt
                 $action = Read-Host $L.SelectOption
                 
                 try {
                     switch ($action) {
                        '1' { 
                            Write-Host $L.ServiceStart
                            Start-Service -Name $svc.Name -ErrorAction Stop
                            Write-Host $L.ServiceSuccess -ForegroundColor Green
                        }
                        '2' { 
                            Write-Host $L.ServiceStop
                            Stop-Service -Name $svc.Name -ErrorAction Stop
                            Write-Host $L.ServiceSuccess -ForegroundColor Green
                        }
                        '3' { 
                            Write-Host $L.ServiceRestart
                            Restart-Service -Name $svc.Name -ErrorAction Stop
                            Write-Host $L.ServiceSuccess -ForegroundColor Green
                        }
                        '4' {
                            Write-Host $L.ServiceType
                            $typeChoice = Read-Host "? (1-3)"
                            switch ($typeChoice) {
                                '1' { Set-Service -Name $svc.Name -StartupType Automatic; Write-Host $L.ServiceSuccess -ForegroundColor Green }
                                '2' { Set-Service -Name $svc.Name -StartupType Manual; Write-Host $L.ServiceSuccess -ForegroundColor Green }
                                '3' { Set-Service -Name $svc.Name -StartupType Disabled; Write-Host $L.ServiceSuccess -ForegroundColor Green }
                            }
                        }
                     }
                     Start-Sleep -Seconds 2
                 } catch {
                     Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                     Pause-Script
                 }
            } elseif ([string]::IsNullOrWhiteSpace($svcName) -eq $false) {
                 Write-Host $L.StartupNotFound -ForegroundColor Red
                 Start-Sleep -Seconds 1
            }
        }
        
    } until ($svcName -eq 'q' -or $svcName -eq 'Q')
}

# ---------------------------------------------------------------------------
# Main Menu Loop
# ---------------------------------------------------------------------------

do {
    Show-Header
    Write-Host $L.Menu_1
    Write-Host $L.Menu_2
    Write-Host $L.Menu_3
    Write-Host $L.Menu_4
    Write-Host $L.Menu_5
    Write-Host $L.Menu_6
    Write-Host $L.Menu_7
    Write-Host $L.Menu_8
    Write-Host $L.Menu_9
    Write-Host $L.Menu_10
    Write-Host $L.Menu_11
    Write-Host $L.Menu_12
    Write-Host $L.Menu_13
    Write-Host $L.Menu_14
    Write-Host "----------------------------------" -ForegroundColor Gray
    Write-Host $L.Menu_A -ForegroundColor Cyan
    Write-Host $L.Menu_Q
    Write-Host "============================================================" -ForegroundColor Cyan
    
    $selection = Read-Host $L.SelectOption
    
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
        '13' { Manage-StartupApps }
        '14' { Manage-Services }
        {$_ -eq 'a' -or $_ -eq 'A'} { Run-CommonMaintenance }
        {$_ -eq 'q' -or $_ -eq 'Q'} { return }
        Default { Write-Warning $L.InvalidSel; Start-Sleep -Seconds 1 }
    }
} until ($selection -eq 'q' -or $selection -eq 'Q')
