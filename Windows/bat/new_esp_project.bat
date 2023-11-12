@echo off
set folder_name=esp_TEMPLATE
set /p new_folder_name=Enter the name of the new folder:
set script_dir=%~dp0
xcopy /e /i "%script_dir%%folder_name%" "%script_dir%%new_folder_name%"
rd /s /q "%script_dir%%new_folder_name%\.git"