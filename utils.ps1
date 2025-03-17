function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = "$env:USERPROFILE\Desktop\scriptstuff\setup.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $LogFile -Value $logMessage
    Write-Output $logMessage
}

function Download-FileWithBITS {
    param (
        [string]$url,
        [string]$output
    )

    Write-Log "Downloading file from $url to $output..."
    Start-BitsTransfer -Source $url -Destination $output
    Write-Log "Download completed."
}