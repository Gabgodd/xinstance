function Set-UltimatePerformancePowerPlan {
    Write-Log "Setting power plan to Ultimate Performance..."
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    Write-Log "Ultimate Performance power plan activated."
}