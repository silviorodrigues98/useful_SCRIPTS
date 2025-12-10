# Define os nomes dos serviços
$services = @("wuauserv", "cryptSvc", "bits", "msiserver")

# Para cada serviço na lista de serviços
foreach ($service in $services) {
    # Tenta parar o serviço
    try {
        Stop-Service -Name $service -ErrorAction Stop
    } catch {
        Write-Host "Não foi possível parar o serviço $service"
    }

    # Tenta iniciar o serviço
    try {
        Start-Service -Name $service -ErrorAction Stop
    } catch {
        Write-Host "Não foi possível iniciar o serviço $service"
    }
}

# Renomeia as pastas SoftwareDistribution e Catroot2
Rename-Item -Path "C:\\Windows\\SoftwareDistribution" -NewName "SoftwareDistribution.old" -ErrorAction SilentlyContinue
Rename-Item -Path "C:\\Windows\\System32\\catroot2" -NewName "Catroot2.old" -ErrorAction SilentlyContinue

# Executa o DISM para limpar a imagem do sistema
DISM.exe /Online /Cleanup-Image /StartComponentCleanup
DISM.exe /Online /Cleanup-image /Restorehealth
