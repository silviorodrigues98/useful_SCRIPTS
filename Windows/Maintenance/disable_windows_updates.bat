@echo off
cd /d "%~dp0"
PowerShell -ExecutionPolicy Bypass -File ".\disable_windows_updates.ps1"