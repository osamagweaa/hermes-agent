$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Users\Kahrman\hermes-agent-repo\hermes-backup\sync-backup.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
$principal = New-ScheduledTaskPrincipal -UserId 'Osama' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'HermesAgentDailyBackup' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force -Description 'Daily backup of Hermes Agent config, skills, memory to GitHub'
Write-Host 'Task registered successfully'