@echo off
title Verificador de Chaves (Smart Detection)
color 07
cls

echo ========================================================
echo      VERIFICADOR DE CHAVE DE PRODUTO (SMART SCAN)
echo ========================================================
echo.
echo Executando analise e comparacao automatica...
echo.

REM --- BLOCO POWERSHELL ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$pathSPP = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform';" ^
 "$pathCV  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion';" ^
 "$wmi = (Get-CimInstance -ClassName SoftwareLicensingService);" ^
 "" ^
 "function Decode-Key($digitalProductId) {" ^
 "    if (!$digitalProductId) { return $null }" ^
 "    $chars = 'BCDFGHJKMPQRTVWXY2346789';" ^
 "    $key = '';" ^
 "    $isWin8 = [int]($digitalProductId[66]/6) -band 1;" ^
 "    $last = 0;" ^
 "    for ($i = 24; $i -ge 0; $i--) {" ^
 "        $k = 0;" ^
 "        for ($j = 14; $j -ge 0; $j--) {" ^
 "            $k = $k * 256 -bxor $digitalProductId[52 + $j];" ^
 "            $digitalProductId[52 + $j] = [math]::Floor([double]($k / 24));" ^
 "            $k = $k %% 24;" ^
 "            $last = $k;" ^
 "        }" ^
 "        $key = $chars[$k] + $key;" ^
 "        if (($i %% 5 -eq 0) -and ($i -ne 0)) { $key = '-' + $key; }" ^
 "    }" ^
 "    return $key;" ^
 "}" ^
 "" ^
 "$genericKeys = @{" ^
 "    'YTMG3-N6DKC-DKB77-7M9GH-8HVX7' = 'Win 10/11 Home';" ^
 "    'VK7JG-NPHTM-C97JM-9MPGT-3V66T' = 'Win 10/11 Pro';" ^
 "    '4CPRK-NM3K3-X6XXQ-RXX86-WXCHW' = 'Win 10/11 Home Single Language';" ^
 "    'BT79Q-G7N6G-PGBYW-4YWX6-6F4BT' = 'Win 10/11 Home SL (Alt)';" ^
 "    'YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY' = 'Win 10/11 Education';" ^
 "    'XGVPP-NMH47-7TTHJ-W3FW7-8HV2C' = 'Win 10/11 Enterprise';" ^
 "    '3NF4D-GF9GY-63VKH-QRC3V-7QW8P' = 'Win 10/11 Pro Workstation';" ^
 "    'DXG7C-N36C4-C4HTG-X4T3X-2YV77' = 'Win 10/11 Pro Education';" ^
 "    'NPPR9-FWDCX-D2C8J-H872K-2YT43' = 'Win 10/11 Enterprise (Vol)';" ^
 "    'W269N-WFGWX-YVC9B-4J6C9-T83GX' = 'Win 10/11 Pro (Vol)';" ^
 "    'TX9XD-98N7V-6WMQ6-BX7FG-H8Q99' = 'Win 10/11 Home (Vol)';" ^
 "};" ^
 "" ^
 "function Analyze-Key($key, $label) {" ^
 "    if ([string]::IsNullOrWhiteSpace($key)) {" ^
 "        Write-Host ('   ' + $label + ': Nao encontrada.') -ForegroundColor DarkGray;" ^
 "        return;" ^
 "    }" ^
 "    Write-Host ('   ' + $label + ': ') -NoNewline -ForegroundColor White;" ^
 "    Write-Host $key -NoNewline -ForegroundColor Green;" ^
 "    if ($genericKeys.ContainsKey($key)) {" ^
 "        $desc = $genericKeys[$key];" ^
 "        Write-Host (' [GENERICA - ' + $desc + ']') -ForegroundColor Magenta;" ^
 "        Write-Host '     -> ATENCAO: Esta chave e padrao para Ativacao Digital (Hardware ID).' -ForegroundColor DarkGray;" ^
 "    } else {" ^
 "        Write-Host ' [UNICA]' -ForegroundColor Cyan;" ^
 "        Write-Host '     -> INFO: Chave exclusiva (OEM, Retail ou MAK salva).' -ForegroundColor Gray;" ^
 "    }" ^
 "}" ^
 "" ^
 "Write-Host '--- 1. HARDWARE (BIOS/UEFI) ---' -ForegroundColor Yellow;" ^
 "if ($wmi.OA3xOriginalProductKey) {" ^
 "    Analyze-Key $wmi.OA3xOriginalProductKey 'BIOS Key';" ^
 "} else {" ^
 "    Write-Host '   BIOS Key: Nao ha chave gravada na placa-mae.' -ForegroundColor Red;" ^
 "}" ^
 "" ^
 "Write-Host '--- 2. REGISTRO DO WINDOWS (Decodificacao) ---' -ForegroundColor Yellow;" ^
 "$id1 = (Get-ItemProperty $pathSPP -ErrorAction SilentlyContinue).DigitalProductId;" ^
 "$key1 = Decode-Key($id1);" ^
 "Analyze-Key $key1 'Installed (V1)';" ^
 "" ^
 "$id4 = (Get-ItemProperty $pathSPP -ErrorAction SilentlyContinue).DigitalProductId4;" ^
 "$key4 = Decode-Key($id4);" ^
 "Analyze-Key $key4 'Installed (V4)';" ^
 "" ^
 "$idLegacy = (Get-ItemProperty $pathCV -ErrorAction SilentlyContinue).DigitalProductId;" ^
 "$keyLegacy = Decode-Key($idLegacy);" ^
 "Analyze-Key $keyLegacy 'Legacy Key';" ^
 "" ^
 "Write-Host '--- 3. HISTORICO E BACKUP ---' -ForegroundColor Yellow;" ^
 "$backup = (Get-ItemProperty $pathSPP -ErrorAction SilentlyContinue).BackupProductKeyDefault;" ^
 "Analyze-Key $backup 'Backup Key';" ^
 "" ^
 "$defaultKey = (Get-ItemProperty $pathCV -ErrorAction SilentlyContinue).DefaultProductKey;" ^
 "Analyze-Key $defaultKey 'Default Key';" ^
 ""

echo.
echo --- 4. STATUS ATUAL DA LICENCA (SLMGR) ---
echo (Se voce usa chave MAK/Volume, verifique o 'Canal' e 'Parcial' abaixo)
echo.
cscript //nologo %windir%\system32\slmgr.vbs /dli
echo.
echo --------------------------------------------------------
echo Processo concluido.
pause