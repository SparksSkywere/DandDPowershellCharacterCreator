# Fallback to default localisation (English) if specific localisation fails
function Set-DefaultLocalisation {
    $defaultLocalisationPath = Join-Path $PSScriptRoot "Assets\Localisation\localisation.en.json"
    try {
        $global:Localisation = Get-Content -Path $defaultLocalisationPath | ConvertFrom-Json
        Debug-Log "[Debug] Loaded default localisation (English)"
    } catch {
        throw "[Debug] Failed to load the default localisation file."
    }
}