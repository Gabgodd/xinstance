function Install-DirectX {
    $url = "https://download.microsoft.com/download/1/2/4/124E10CE-F5C1-4AB8-893A-86CDD73AD8E3/directx_Jun2010_redist.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\directx_Jun2010_redist.exe"
    $extractPath = "$env:USERPROFILE\Desktop\scriptstuff\DirectX"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Extracting DirectX..."
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }

    Start-Process -FilePath $output -ArgumentList "/Q /T:$extractPath" -Wait

    Write-Log "Running DXSETUP.exe..."
    $dxSetup = "$extractPath\DXSETUP.exe"
    if (Test-Path $dxSetup) {
        Start-Process -FilePath $dxSetup -ArgumentList "/silent" -Wait
    } else {
        Write-Log "DXSETUP.exe not found in the extracted files!"
    }

    Remove-Item -Path $output -Force
    Write-Log "DirectX setup completed!"
}