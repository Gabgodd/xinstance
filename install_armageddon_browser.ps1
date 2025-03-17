function Install-ArmageddonBrowser {
    $url = "https://github.com/KaladinDMP/AGBrowser/releases/download/v5.5.0/SETUP.7z"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\SETUP.7z"
    $extractPath = "$env:USERPROFILE\Desktop\scriptstuff\ARMGDDN Browser"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Extracting Armageddon Browser..."
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }

    # Use 7-Zip to extract the downloaded file
    $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"  # Ensure this is the correct path to 7-Zip
    Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$output`" -o`"$extractPath`"" -Wait

    Write-Log "Running INSTALL.bat..."
    $installBat = "$extractPath\INSTALL.bat"
    if (Test-Path $installBat) {
        Start-Process -FilePath $installBat -Wait
    } else {
        Write-Log "INSTALL.bat not found in the extracted files!"
    }

    Write-Log "Armageddon Browser setup completed!"
}