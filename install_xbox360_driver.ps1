function Install-Xbox360ControllerDriver {
    $url = "https://github.com/Gabgodd/xinstance/blob/main/Xbox360_64Eng.exe?raw=true"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\Xbox360_64Eng.exe"

    Download-FileWithBITS -url $url -output $output

    if (Test-Path $output) {
        Write-Log "Installing Xbox 360 Controller Driver..."
        Start-Process -FilePath $output -Wait
        Remove-Item -Path $output -Force
        Write-Log "Xbox 360 Controller Driver installed successfully!"
    } else {
        Write-Log "Failed to download Xbox 360 Controller Driver. Please check the URL."
    }
}