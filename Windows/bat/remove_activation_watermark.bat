@echo off
taskkill /F /IM explorer.exe
explorer.exe
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v PaintDesktopVersion /t REG_SZ /d 1 /f
exit
