@echo off
cls
@REM COLOCAR AQUI O CAMINHO COMPLETO ATÉ A POSTA ONDE ESTÃO OS .BAT OU .MSI
set pathToFiles=C:\Users\Silvio\Downloads\testingBATCH\
@REM THE IDEA IS TO HAVE TWO FOLDERS FOR WINDOWS, ONE 32 AND ONE 64 BITS.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
if %OS%==32BIT set pathToFiles=%pathToFiles%x86\
if %OS%==64BIT set pathToFiles=%pathToFiles%x64\
@REM CHECKS IF FOLDER EXISTS, AND IF IT DOESN'T, IT BREAKS THE PROGRAM
if not exist "%pathToFiles%" (
    echo O DIRETORIO ESPECIFICADO NO .BAT NAO FOI ENCONTRADO, FAVOR ALTERAR A CONFIGURACAO.
    echo PRESSIONE QUALQUER TELA PARA FECHAR ESTA JANELA
    pause
    exit
)
echo. 
echo.
timeout 1 >nul
echo SISTEMA DE %OS%, ARQUIVOS CONTIDOS NA PASTA %pathToFiles%.
echo CONFIRA SE EXECUTOU EM MODO ADMINISTRADOR E SE AS INFORMACOES ACIMA ESTAO CERTAS.
echo A INSTALACAO PODE DEMORAR UM POUCO, AGUARDE ATE O FINAL DA MESMA, 
echo E NAO FACA OPERACOES QUE SOBRECARREGUEM O SISTEMA.
pause
echo. 
echo.
echo INICIANDO INSTALACAO DE ARQUIVOS EXE...
echo. 
echo.
timeout 3 >nul
setlocal DisableDelayedExpansion
@REM THIS WILL LOOP ALL .EXE FILES INSIDE THE FOLDER AND INSTALL THEM
for %%I in ("%pathToFiles%*.exe") do (
    echo INSTALANDO: %%~nI
    timeout 2 >nul
    start "Running %%~nI" /wait "%%I" /S /s /v/qn /quiet /passive /silent /VERYSILENT /exenoui /norestart /log
    echo.
    echo.
)
echo INICIANDO INSTALACAO DE ARQUIVOS MSI...
echo. 
echo.
timeout 3 >nul
@REM THIS WILL LOOP ALL .MSI FILES INSIDE THE FOLDER AND INSTLAL THEM
for %%I in ("%pathToFiles%*.msi") do (
    echo INSTALANDO: %%~nI
    timeout 2 >nul
    msiexec /i %%I /quiet /qb! /l*v install.log /norestart 
    echo.
    echo.
)
endlocal
echo. 
echo.
@REM //TODO FIND A WAY TO VERIFY IF PROGRAMS WERE INSTALLED AUTOMATICALLY
@REM THIS WILL OPEN PROGRAMS MANAGER, SO THAT YOU CAN SEE IF THE PROGRAM WAS PROPERLY INSTALLED
appwiz.cpl
echo INSTALACAO FINALIZADA, CONFIRA SE OS PROGRAMAS FORAM INSTALADOS CORRETAMENTE.
pause
