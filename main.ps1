# Main script to orchestrate the setup process

# Ensure the script runs with administrative privileges
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Exit
}

# Create folder for logs and downloaded files
$folderPath = "$env:USERPROFILE\Desktop\scriptstuff"
If (-Not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

# Import utility functions
. .\utils.ps1

# Import individual scripts
. .\decrypt_credentials.ps1
. .\install_nvidia_drivers.ps1
. .\system_configuration.ps1
. .\install_7zip.ps1
. .\install_sunshine.ps1
. .\install_armageddon_browser.ps1
. .\install_google_chrome.ps1
. .\install_opencomposite.ps1
. .\install_xbox360_driver.ps1
. .\install_xbox_app.ps1
. .\install_virtual_desktop.ps1
. .\install_directx.ps1
. .\set_performance_power_plan.ps1
. .\configure_firewall.ps1

# Call individual scripts
Decrypt-AWSCredentials
Configure-System
Install-7Zip
Install-Sunshine
Install-ArmageddonBrowser
Install-NvidiaDriversAWS
Install-GoogleChrome
Install-OpenComposite
Install-Xbox360ControllerDriver
Install-XboxApp
Install-VirtualDesktop
Install-DirectX
Set-UltimatePerformancePowerPlan
Configure-Firewall

Write-Log "VM setup is complete."

# Keep window open for review
Read-Host -Prompt "Press Enter to exit"