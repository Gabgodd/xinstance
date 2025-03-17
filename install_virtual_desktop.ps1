function Install-VirtualDesktop {
    $url = "https://download.vrdesktop.net/files/VirtualDesktop.Streamer.Setup.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\VirtualDesktop.Streamer.Setup.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing Virtual Desktop..."
    Start-Process -FilePath $output -Wait
    Remove-Item -Path $output -Force
    Write-Log "Virtual Desktop installed successfully!"
}