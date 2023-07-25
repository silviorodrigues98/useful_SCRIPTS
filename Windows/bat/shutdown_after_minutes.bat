@echo off
setlocal enableextensions enabledelayedexpansion

rem Altere a página de código do console para 1252
chcp 1252 >nul

rem Cancelar todos os desligamentos agendados
shutdown -a

:loop
set /p _minutos="Quantos minutos a partir de agora voce deseja que o computador seja desligado? "
set /a minutos=_minutos

rem Verifique se a entrada contem apenas numeros
if !minutos! EQU 0 (
  if !_minutos! EQU 0 (
    echo %minutos%
  ) else (
    echo Digite um numero inteiro valido
    goto loop
  )
) else (
  echo %minutos%
)

rem Converta os minutos em segundos e continue com o script
set /a segundos=%minutos%*60
echo O computador sera desligado em %minutos% minutos.
shutdown -s -t %segundos%

echo.

rem Altere a página de código do console de volta para 850
chcp 850 >nul

echo Para cancelar o desligamento agendado, voce pode fazer o seguinte:
echo.
echo * Abra um prompt de comando e digite `shutdown -a`.
echo * Abra a Agendador de Tarefas e localize a tarefa que esta agendada para desligar o seu computador. Clique com o botao direito do mouse na tarefa e selecione "Desabilitar".

pause
