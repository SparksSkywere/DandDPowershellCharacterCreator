# Wrapper function to handle conditional logging
function Debug-Log {
    param (
        [string]$Message
    )
    if ($global:DebugLoggingEnabled) {
        Write-Host $Message
    }
}