# Detect system language and load corresponding localisation file
function Set-Localisation {
    # Get the current system culture (e.g., "en-US" or "es-ES")
    $currentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    $languageCode = $currentCulture.Split('-')[0]  # Get the language part (e.g., "en" or "es")

    $localisationPath = Join-Path $PSScriptRoot "Assets\Localisation\localisation.$languageCode.json"
    if (Test-Path $localisationPath) {
        try {
            $global:Localisation = Get-Content -Path $localisationPath -Raw -Encoding UTF8 | ConvertFrom-Json
            Debug-Log "[Debug] Loaded localisation for language: $languageCode"
        } catch {
            Write-Warning "[Debug] Failed to load localisation file for language '$languageCode'. Error: $_"
            Set-DefaultLocalisation
        }
    } else {
        Write-Warning "[Debug] Localisation file not found for language '$languageCode'. Falling back to default (English)."
        Set-DefaultLocalisation
    }
}