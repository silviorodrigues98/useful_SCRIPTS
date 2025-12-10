$taskName = "Scheduled Shutdown"
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
}
catch {
    Write-Warning "No existing scheduled shutdown found"
}
$date = Read-Host -Prompt 'Enter the date and time for shutdown (e.g. "07/23/2023 23:00")'
try {
    $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/s /f /t 0"
    $trigger = New-ScheduledTaskTrigger -Once -At $date
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger
    Write-Host "Shutdown scheduled for $date. To cancel, run this script again or run 'Unregister-ScheduledTask -TaskName "$taskName" -Confirm'"
}
catch {
    Write-Error "Failed to schedule shutdown: $_"
}
