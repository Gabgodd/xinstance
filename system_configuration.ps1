function Configure-System {
    # 1 - Force Change Password to Gabgod10@
    $Username = "Administrator"
    $NewPassword = ConvertTo-SecureString "Gabgod10@" -AsPlainText -Force

    # Check if the Administrator account exists
    if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
        # Enable the Administrator account if it's disabled
        Enable-LocalUser -Name $Username

        # Change the password
        Set-LocalUser -Name $Username -Password $NewPassword
        Write-Log "Password changed successfully for $Username."
    } else {
        Write-Log "User $Username not found. Skipping password change."
    }

    # 2 - Auto-Login Script
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    # Set AutoAdminLogon, DefaultUsername, and DefaultPassword
    Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1" -Type String
    Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value $Username -Type String
    Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value "Gabgod10@" -Type String
    Write-Log "Auto-login configured successfully for $Username."

    # 3 - Remove Logon Screen Delay (Skip Welcome/Login screen)
    Set-ItemProperty -Path $RegPath -Name "DisableLockWorkstation" -Value "1" -Type DWord
    Set-ItemProperty -Path $RegPath -Name "DontDisplayLockedUserID" -Value "3" -Type DWord
    Write-Log "Logon screen delay removed."

    # 4 - Disable Ctrl+Alt+Del Requirement
    $CADPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $CADPath -Name "DisableCAD" -Value "1" -Type DWord
    Write-Log "Ctrl+Alt+Del requirement disabled."

    Write-Log "All settings applied successfully. Restart for changes to take effect."
}