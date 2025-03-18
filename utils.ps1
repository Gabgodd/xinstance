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

# Function to download files using BITS
function Download-FileWithBITS {
    param (
        [string]$url,
        [string]$output
    )

    Write-Log "Starting BITS transfer for $url..."
    $bitsJob = Start-BitsTransfer -Source $url -Destination $output -Asynchronous

    # Wait for the BITS transfer to complete
    while ($bitsJob.JobState -eq [Microsoft.BackgroundIntelligentTransfer.Management.JobState]::Transferring) {
        Write-Host "Downloading... $($bitsJob.BytesTransferred) of $($bitsJob.BytesTotal) bytes transferred."
        Start-Sleep -Seconds 5
    }

    if ($bitsJob.JobState -eq [Microsoft.BackgroundIntelligentTransfer.Management.JobState]::Transferred) {
        Complete-BitsTransfer -BitsJob $bitsJob
        Write-Log "Download completed successfully for $url."
    } else {
        Remove-BitsTransfer -BitsJob $bitsJob -Force
        Throw "BITS transfer failed with state: $($bitsJob.JobState)"
    }
}
