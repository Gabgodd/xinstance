function Decrypt-AWSCredentials {
    # Prompt for password
    $password = Read-Host -Prompt "Enter the password to decrypt AWS credentials"

    # Decrypt credentials
    $encryptedFile = "$env:USERPROFILE\Desktop\aws_credentials.enc"
    if (-not (Test-Path $encryptedFile)) {
        Write-Log "Encrypted credentials file not found on Desktop. Please ensure aws_credentials.enc is present."
        return $null
    }

    $encryptedCredentials = Get-Content -Path $encryptedFile
    $secureString = ConvertTo-SecureString -String $encryptedCredentials -Key (1..32 | ForEach-Object { [byte]$_ })
    $credentials = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

    # Verify the password
    if ($password -eq "2023") {
        $decryptedCredentials = $credentials -split ","
        $awsAccessKey = $decryptedCredentials[0]
        $awsSecretKey = $decryptedCredentials[1]
        
        Write-Log "AWS credentials decrypted successfully."
        return @($awsAccessKey, $awsSecretKey)
    } else {
        Write-Log "Incorrect password. Script cannot proceed."
        return $null
    }
}