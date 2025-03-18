# Utility functions

# Function to write logs
function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = "$env:USERPROFILE\Desktop\scriptstuff\setup.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    
    # Ensure the logging directory exists
    $logDir = [System.IO.Path]::GetDirectoryName($LogFile)
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force
    }

    Add-Content -Path $LogFile -Value $logMessage
    Write-Output $logMessage
}
