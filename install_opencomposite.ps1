function Install-OpenComposite {
    $url = "https://znix.xyz/OpenComposite/runtimeswitcher.php?branch=openxr"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\OpenComposite.zip"
    $extractPath = "$env:USERPROFILE\Desktop\scriptstuff\OpenComposite"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Extracting OpenComposite..."
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }
    Expand-Archive -Path $output -DestinationPath $extractPath -Force

    # Handle nested folder structure
    $nestedFolder = "$extractPath\OpenComposite"
    if (Test-Path $nestedFolder) {
        Get-ChildItem -Path $nestedFolder | Move-Item -Destination $extractPath -Force
        Remove-Item -Path $nestedFolder -Recurse -Force
    }

    Write-Log "Running OpenComposite.exe..."
    $openCompositeExe = "$extractPath\OpenComposite.exe"
    if (Test-Path $openCompositeExe) {
        Start-Process -FilePath $openCompositeExe
    } else {
        Write-Log "OpenComposite.exe not found in the extracted files!"
    }

    Remove-Item -Path $output -Force
    Write-Log "OpenComposite Runtime Switcher setup completed!"
}