function Configure-Firewall {
    Write-Log "Configuring firewall rules for Sunshine and Moonlight..."

    # Define Sunshine ports
    $sunshinePorts = @(47984, 47989, 48010)

    # Allow inbound and outbound traffic for Sunshine ports
    foreach ($port in $sunshinePorts) {
        New-NetFirewallRule -DisplayName "Sunshine_TCP_$port" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -Profile Any -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "Sunshine_UDP_$port" -Direction Inbound -Protocol UDP -LocalPort $port -Action Allow -Profile Any -ErrorAction SilentlyContinue
    }

    Write-Log "Firewall rules for Sunshine and Moonlight have been added successfully."
}