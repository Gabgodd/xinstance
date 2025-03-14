# Ensure the script runs in a new window and waits for user input
if (-not ($Host.UI.RawUI.WindowTitle -match "Admin")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Create scriptstuff folder on the desktop
$scriptstuffFolder = "$env:USERPROFILE\Desktop\scriptstuff"
if (-not (Test-Path $scriptstuffFolder)) {
    New-Item -ItemType Directory -Path $scriptstuffFolder | Out-Null
    Write-Host "Created scriptstuff folder on Desktop." -ForegroundColor Green
}

# Function to log messages to a debug file
function Write-Log {
    param (
        [string]$Message
    )
    $logFile = "$scriptstuffFolder\debug.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $Message
}

# Function to decrypt AWS credentials
function Get-DecryptedCredentials {
    param (
        [string]$Password
    )
    $encryptedFile = "$env:USERPROFILE\Desktop\aws_credentials.enc"
    if (-not (Test-Path $encryptedFile)) {
        Write-Log "Encrypted credentials file not found on Desktop. Please ensure aws_credentials.enc is present."
        return $null
    }

    $encryptedCredentials = Get-Content -Path $encryptedFile
    $secureString = ConvertTo-SecureString -String $encryptedCredentials
    $credentials = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

    # Verify the password
    if ($Password -eq "2023") {
        return $credentials -split ","
    } else {
        Write-Log "Incorrect password. Script cannot proceed."
        return $null
    }
}

# Prompt for password
$password = Read-Host -Prompt "Enter the password to decrypt AWS credentials"
$credentials = Get-DecryptedCredentials -Password $password

if (-not $credentials) {
    exit
}

# Use the decrypted credentials
$awsAccessKey = $credentials[0]
$awsSecretKey = $credentials[1]

# 1 - Force Change Password to Gabgod10@
$Username = "Administrator"
$NewPassword = ConvertTo-SecureString "Gabgod10@" -AsPlainText -Force

# Check if the Administrator account exists
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    # Enable the Administrator account if it's disabled
    Enable-LocalUser -Name $Username

    # Change the password
    Set-LocalUser -Name $Username -Password $NewPassword
    Write-Log "Password changed successfully for $Username."
} else {
    Write-Log "User $Username not found. Skipping password change."
}

# 2 - Auto-Login Script
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Set AutoAdminLogon, DefaultUsername, and DefaultPassword
Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1" -Type String
Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value $Username -Type String
Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value "Gabgod10@" -Type String
Write-Log "Auto-login configured successfully for $Username."

# 3 - Remove Logon Screen Delay (Skip Welcome/Login screen)
Set-ItemProperty -Path $RegPath -Name "DisableLockWorkstation" -Value "1" -Type DWord
Set-ItemProperty -Path $RegPath -Name "DontDisplayLockedUserID" -Value "3" -Type DWord
Write-Log "Logon screen delay removed."

# 4 - Disable Ctrl+Alt+Del Requirement
$CADPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $CADPath -Name "DisableCAD" -Value "1" -Type DWord
Write-Log "Ctrl+Alt+Del requirement disabled."

Write-Log "All settings applied successfully. Restart for changes to take effect."

# Function to download files using BITS
function Download-FileWithBITS {
    param (
        [string]$url,
        [string]$output
    )
    Write-Log "Downloading $url to $output using BITS..."
    Start-BitsTransfer -Source $url -Destination $output -DisplayName "Downloading $output"
    Write-Log "Download completed: $output"
}

# Function to install 7-Zip
function Install-7Zip {
    $url = "https://www.7-zip.org/a/7z2409-x64.exe"
    $output = "$scriptstuffFolder\7z2409-x64.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing 7-Zip..."
    Start-Process -FilePath $output -ArgumentList "/S" -Wait
    Write-Log "7-Zip installed successfully!"
}

# Function to install Sunshine
function Install-Sunshine {
    $url = "https://github.com/LizardByte/Sunshine/releases/download/v2025.122.141614/sunshine-windows-installer.exe"
    $output = "$scriptstuffFolder\sunshine-windows-installer.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing Sunshine..."
    Start-Process -FilePath $output -Wait
    Write-Log "Sunshine installed successfully!"
}

# Function to install Armageddon Browser
function Install-ArmageddonBrowser {
    $url = "https://github.com/KaladinDMP/AGBrowser/releases/download/v5.5.0/SETUP.7z"
    $output = "$scriptstuffFolder\SETUP.7z"
    $extractPath = "$scriptstuffFolder\ARMGDDN Browser"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Extracting Armageddon Browser..."
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }
    Start-Process -FilePath "$scriptstuffFolder\7z2409-x64.exe" -ArgumentList "x `"$output`" -o`"$extractPath`"" -Wait

    Write-Log "Running INSTALL.bat..."
    $installBat = "$extractPath\INSTALL.bat"
    if (Test-Path $installBat) {
        Start-Process -FilePath $installBat -Wait
    } else {
        Write-Log "INSTALL.bat not found in the extracted files!"
    }

    Write-Log "Armageddon Browser setup completed!"
}

# Function to install NVIDIA drivers on AWS
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
    $LocalPath = "$scriptstuffFolder\NVIDIA"
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
}

# Main script execution
Write-Log "Starting VM setup..."

# Run functions in the specified order
Install-Sunshine
Install-7Zip
Install-ArmageddonBrowser
Install-NvidiaDriversAWS
Install-GoogleChrome
Install-OpenComposite
Install-Xbox360ControllerDriver
Install-XboxApp
Install-VirtualDesktop
Set-UltimatePerformancePowerPlan
Configure-Firewall

# Set display settings and disable RDP display
Set-DisplaySettings
Disable-RDPDisplay

Write-Log "VM setup completed!"

# Keep the window open
Read-Host -Prompt "Press Enter to exit..."