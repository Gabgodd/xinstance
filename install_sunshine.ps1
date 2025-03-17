function Install-Sunshine {
    $url = "https://github.com/LizardByte/Sunshine/releases/download/v2025.122.141614/sunshine-windows-installer.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\sunshine-windows-installer.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing Sunshine..."
    Start-Process -FilePath $output -Wait
    Write-Log "Sunshine installed successfully!"
}