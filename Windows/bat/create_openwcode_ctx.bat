@echo off
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode" /ve /d "Open with Code" /f
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode\command" /ve /d "\"C:\Users\%UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe\" \"%V\"" /f
echo "Open with Code" added to context menu for folders.
