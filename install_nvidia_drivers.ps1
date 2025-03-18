# Import the decryption script
. "$PSScriptRoot\decrypt_credentials.ps1"

# Define the function to install NVIDIA drivers using AWS credentials
function Install-NvidiaDriversAWS {
    param (
        [string]$awsAccessKey,
        [string]$awsSecretKey
    )

    Write-Log "Setting up AWS credentials and installing NVIDIA drivers..."

    # Step 1: Install AWSPowerShell module if not already installed
    if (-not (Get-Module -ListAvailable -Name AWSPowerShell)) {
        Write-Log "Installing AWSPowerShell module..."
        Install-Module -Name AWSPowerShell -Force -AllowClobber -Verbose
    } else {
        Write-Log "AWSPowerShell module is already installed."
    }

    # Step 2: Set AWS credentials
    Write-Log "Setting AWS credentials..."
    Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs default -Verbose

    # Step 3: Verify AWS credentials
    Write-Log "Verifying AWS credentials..."
    $credentials = Get-AWSCredential -ProfileName default
    if ($credentials -eq $null) {
        Write-Log "Failed to verify AWS credentials!"
        return
    }
    Write-Log "AWS credentials verified successfully!"

    # Step 4: Download and install NVIDIA drivers
    Write-Log "Downloading NVIDIA drivers..."
    $Bucket = "ec2-windows-nvidia-drivers"
    $KeyPrefix = "latest"
    $LocalPath = "$env:USERPROFILE\Desktop\scriptstuff\NVIDIA"
    New-Item -ItemType Directory -Path $LocalPath -Force
    try {
        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1 -Verbose
        foreach ($Object in $Objects) {
            $LocalFileName = $Object.Key
            if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $LocalFileName
                Write-Log "Downloading $LocalFileName..."
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1 -Verbose
            }
        }
        Write-Log "NVIDIA drivers downloaded successfully!"
    } catch {
        Write-Log "Failed to download NVIDIA drivers: $_"
        return
    }

    # Step 5: Install NVIDIA drivers
    Write-Log "Installing NVIDIA drivers..."
    $driverInstaller = Get-ChildItem -Path "$LocalPath" -Filter *.exe | Select-Object -First 1
    if ($driverInstaller) {
        Start-Process -FilePath $driverInstaller.FullName -ArgumentList "/s" -Wait -Verbose
        Write-Log "NVIDIA drivers installed successfully!"
    } else {
        Write-Log "No NVIDIA driver installer found in $LocalPath!"
    }

    # Step 6: Disable default wired display
    Write-Log "Disabling default wired display..."
    $wiredDisplay = Get-PnpDevice -FriendlyName "Wired Display" -ErrorAction SilentlyContinue
    if ($wiredDisplay) {
        Disable-PnpDevice -InstanceId $wiredDisplay.InstanceId -Confirm:$false -Verbose
        Write-Log "Default wired display disabled."
    } else {
        Write-Log "Wired display not found or already disabled."
    }
}

# Main script execution
$credentials = Decrypt-AWSCredentials
if ($credentials -ne $null) {
    $awsAccessKey = $credentials[0]
    $awsSecretKey = $credentials[1]
    Install-NvidiaDriversAWS -awsAccessKey $awsAccessKey -awsSecretKey $awsSecretKey
} else {
    Write-Log "AWS credentials not available. Skipping NVIDIA drivers installation."
}

Write-Log "Script execution completed."
