function Install-GoogleChrome {
    $url = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B001A1E7A-A900-0CCD-1811-F7588B3E7379%7D%26lang%3Dpt-BR%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
    $output = "$env:USERPROFILE\Desktop\scriptstuff\ChromeSetup.exe"

    Download-FileWithBITS -url $url -output $output

    Write-Log "Installing Google Chrome..."
    Start-Process -FilePath $output -Wait
    Remove-Item -Path $output -Force
    Write-Log "Google Chrome installed successfully!"
}