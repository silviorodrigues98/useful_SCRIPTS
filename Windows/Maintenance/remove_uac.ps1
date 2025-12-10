$taskName = "Run Program Without UAC - User Logged In"
$programPath = '"C:\Program Files (x86)\PATH_TO_YOUR\EXECUTABLE.EXE"'
$description = "Runs the specified program with elevated privileges when user is logged in, bypassing UAC"

# Create the scheduled task
$action = New-ScheduledTaskAction -Execute $programPath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName) -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 0)

$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description $description
Register-ScheduledTask -TaskName $taskName -InputObject $task -Force

# Create a shortcut on the user's desktop to run the scheduled task
$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "$taskName.lnk")
$targetPath = 'C:\Windows\System32\schtasks.exe'
$arguments = "/run /tn `"$taskName`""

# Create the COM object for the shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)

$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.WorkingDirectory = [System.Environment]::GetFolderPath('Desktop')
$shortcut.WindowStyle = 1
$shortcut.Description = "Shortcut to run the $taskName task"
$shortcut.Save()
