function Install-NvidiaDriversAWS {
    Write-Log "Setting up AWS credentials and installing NVIDIA drivers..."

    # Step 1: Install NuGet package provider
    Write-Log "Installing NuGet package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

    # Step 2: Install AWSPowerShell module
    Write-Log "Installing AWSPowerShell module..."
    Install-Module -Name AWSPowerShell -Force -AllowClobber

    # Step 3: Set AWS credentials
    Write-Log "Setting AWS credentials..."
    Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs default

    # Step 4: Verify AWS credentials
    Write-Log "Verifying AWS credentials..."
    $credentials = Get-AWSCredential -ProfileName default
    if ($credentials) {
        Write-Log "AWS credentials verified successfully!"
    } else {
        Write-Log "Failed to verify AWS credentials!"
        return
    }

    # Step 5: Download and install NVIDIA drivers
    Write-Log "Downloading NVIDIA drivers..."
    $Bucket = "ec2-windows-nvidia-drivers"
    $KeyPrefix = "latest"
    $LocalPath = "$env:USERPROFILE\Desktop\scriptstuff\NVIDIA"
    New-Item -ItemType Directory -Path $LocalPath -Force
    $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
    foreach ($Object in $Objects) {
        $LocalFileName = $Object.Key
        if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
            $LocalFilePath = Join-Path $LocalPath $LocalFileName
            Write-Log "Downloading $LocalFileName..."
            Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
        }
    }
    Write-Log "NVIDIA drivers downloaded successfully!"

    # Step 6: Install NVIDIA drivers
    Write-Log "Installing NVIDIA drivers..."
    $driverInstaller = Get-ChildItem -Path "$LocalPath" -Filter *.exe | Select-Object -First 1
    if ($driverInstaller) {
        Start-Process -FilePath $driverInstaller.FullName -ArgumentList "/s" -Wait
        Write-Log "NVIDIA drivers installed successfully!"
    } else {
        Write-Log "No NVIDIA driver installer found in $LocalPath!"
    }

    # Step 7: Disable default wired display
    Write-Log "Disabling default wired display..."
    $wiredDisplay = Get-PnpDevice -FriendlyName "Wired Display" -ErrorAction SilentlyContinue
    if ($wiredDisplay) {
        Disable-PnpDevice -InstanceId $wiredDisplay.InstanceId -Confirm:$false
        Write-Log "Default wired display disabled."
    } else {
        Write-Log "Wired display not found or already disabled."
    }
}