param()

$ErrorActionPreference = "Stop"
$taskName = "ACP Daemon"
$logFile = "$env:TEMP\acp-daemon.log"

Write-Host "Restarting ACP daemon..."

try {
    Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
    Start-Sleep -Seconds 2
    Start-ScheduledTask -TaskName $taskName | Out-Null
} catch {
    Write-Host "Error: failed to restart '$taskName' scheduled task."
    Write-Host "Make sure the daemon was installed with setup-autostart.ps1 -Install"
    exit 1
}

Write-Host "Waiting for new pairing code..."

for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Seconds 1
    if (Test-Path $logFile) {
        $match = Select-String -Path $logFile -Pattern "Device Code:\s+(\d+)" | Select-Object -Last 1
        if ($match -and $match.Matches.Groups[1].Value) {
            $code = $match.Matches.Groups[1].Value
            Write-Host ""
            Write-Host "╔═══════════════════════╗"
            Write-Host "║  Device Code: $($code.PadRight(6))  ║"
            Write-Host "╚═══════════════════════╝"
            Write-Host ""
            exit 0
        }
    }
}

Write-Host "Error: could not retrieve pairing code within 15 seconds"
Write-Host "Check $logFile for the code."
exit 1
