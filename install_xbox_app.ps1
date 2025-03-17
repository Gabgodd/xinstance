function Install-XboxApp {
    $url = "https://dlassets-ssl.xboxlive.com/public/content/XboxInstaller/XboxInstaller.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\XboxInstaller.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing Xbox App..."
    Start-Process -FilePath $output -Wait
    Remove-Item -Path $output -Force
    Write-Log "Xbox App installed successfully!"
}