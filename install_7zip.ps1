function Install-7Zip {
    $url = "https://www.7-zip.org/a/7z2409-x64.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\7z2409-x64.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing 7-Zip..."
    Start-Process -FilePath $output -ArgumentList "/S" -Wait
    Write-Log "7-Zip installed successfully!"
}