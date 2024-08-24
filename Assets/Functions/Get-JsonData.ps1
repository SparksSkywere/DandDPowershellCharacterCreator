# Function to load JSON data from a given path
function Get-JsonData($path) {
    $jsonFiles = Get-ChildItem -Path $path -Filter *.json -ErrorAction Stop
    $data = @()

    foreach ($file in $jsonFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $jsonData = $content | ConvertFrom-Json -ErrorAction Stop
            $data += $jsonData
        } catch {
            Write-Warning "Failed to load JSON from file: $($file.FullName). Error: $($_.Exception.Message)"
        }
    }
    return $data
}