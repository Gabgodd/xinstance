# Define the function to write logs
function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = "$env:USERPROFILE\Desktop\scriptstuff\setup.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    
    # Ensure the logging directory exists
    $logDir = [System.IO.Path]::GetDirectoryName($LogFile)
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force
    }

    Add-Content -Path $LogFile -Value $logMessage
    Write-Output $logMessage
}

# Define the function to decrypt AWS credentials
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
    $encryptedBytes = [Convert]::FromBase64String($encryptedCredentials)

    # Encryption key and IV (use the same key and IV as in the encryption script)
    $key = [System.Text.Encoding]::UTF8.GetBytes($password.PadRight(32, ' '))
    $iv = (1..16 | ForEach-Object { [byte]$_ })

    # Decrypt the credentials using AES
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV)

    $ms = New-Object System.IO.MemoryStream
    $ms.Write($encryptedBytes, 0, $encryptedBytes.Length)
    $ms.Position = 0

    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
    $sr = New-Object System.IO.StreamReader($cs)
    $credentials = $sr.ReadToEnd()
    $sr.Close()
    $cs.Close()
    $ms.Close()

    # Verify the password
    if ($password -eq "awskey") {
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
