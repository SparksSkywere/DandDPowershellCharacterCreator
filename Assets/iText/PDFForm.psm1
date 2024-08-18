#Requires -Version 4

# Function to locate or download the iTextSharp library.
function Find-ITextSharpLibrary {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param()

    begin {
        $ErrorActionPreference = 'Stop'
    }

    process {
        try {
            # Define the path to the local iTextSharp DLL file.
            $localLibraryPath = Join-Path -Path $PSScriptRoot -ChildPath 'itextsharp.dll'

            # Check if the DLL exists locally.
            if (Test-Path -Path $localLibraryPath) {
                Write-Verbose -Message "Found iTextSharp library at [$localLibraryPath]."
                return Get-Item -Path $localLibraryPath
            }
            else {
                Write-Verbose -Message "iTextSharp library not found locally. Downloading..."

                # Download the iTextSharp library from SourceForge.
                $tempFile = [System.IO.Path]::GetTempFileName()
                $params = @{
                    'Uri'       = 'https://sourceforge.net/projects/itextsharp/files/latest/download'
                    'OutFile'   = $tempFile
                    'UserAgent' = [Microsoft.PowerShell.Commands.PSUserAgent]::Firefox
                }
                Invoke-WebRequest @params

                # Verify the download was successful by checking the file size.
                if ((Get-Item -Path $tempFile).Length -lt 54000) {
                    throw 'ITextLibrary download failed. Go to https://sourceforge.net/projects/itextsharp to download manually.'
                }
                else {
                    Write-Verbose -Message "Extracting iTextSharp library..."
                    
                    # Extract the downloaded ZIP file to the temporary directory.
                    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
                    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempFile, $env:TEMP)

                    # Attempt to locate the extracted DLL.
                    $extractedDllPath = Join-Path -Path $env:TEMP -ChildPath 'itextsharp.dll'
                    if (Test-Path -Path $extractedDllPath) {
                        return Get-Item -Path $extractedDllPath
                    }
                    else {
                        throw 'Failed to find iTextSharp DLL after extraction.'
                    }
                }
            }
        }
        catch {
            # Handle any errors by throwing a terminating error.
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

# Function to retrieve all field names from a PDF file using the iTextSharp library.
function Get-PdfFieldNames {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.pdf$')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$FilePath,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.dll$')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$ITextLibraryPath = (Find-ITextSharpLibrary).FullName
    )

    begin {
        $ErrorActionPreference = 'Stop'
        # Load the iTextSharp DLL to access its functions.
        [System.Reflection.Assembly]::LoadFrom($ITextLibraryPath) | Out-Null
    }

    process {
        try {
            # Create a PdfReader object to read the PDF file.
            $reader = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $FilePath
            # Return the names of all form fields in the PDF.
            $reader.AcroFields.Fields.Key
        }
        catch {
            # Handle any errors by throwing a terminating error.
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

# Function to fill and save PDF form fields, and optionally add images.
function Save-PdfField {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$Fields,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.pdf$')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$InputPdfFilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.pdf$')]
        [ValidateScript({ -not (Test-Path -Path $_ -PathType Leaf) })]
        [string]$OutputPdfFilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.dll$')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$ITextSharpLibrary = (Find-ITextSharpLibrary).FullName,

        [Parameter()]
        [Hashtable]$ImageFields = @{}
    )

    begin {
        $ErrorActionPreference = 'Stop'
    }

    process {
        try {
            # Load the iTextSharp library for PDF manipulation.
            [System.Reflection.Assembly]::LoadFrom($ITextSharpLibrary) | Out-Null

            # Create PdfReader and PdfStamper objects to read and modify the PDF.
            $reader = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $InputPdfFilePath
            $stamper = New-Object iTextSharp.text.pdf.PdfStamper($reader, [System.IO.File]::Create($OutputPdfFilePath))
            $acroFields = $stamper.AcroFields

            # Fill out text fields in the PDF with provided values.
            foreach ($field in $Fields.GetEnumerator()) {
                if (-not [string]::IsNullOrEmpty($field.Value)) {
                    $acroFields.SetField($field.Key, $field.Value) | Out-Null
                } else {
                    Write-Verbose "Skipping empty or null field: $($field.Key)"
                }
            }

            # Insert images into specified fields in the PDF.
            foreach ($imageField in $ImageFields.GetEnumerator()) {
                $imagePath = $imageField.Value
                if (Test-Path -Path $imagePath -PathType Leaf) {
                    $image = [iTextSharp.text.Image]::GetInstance($imagePath)
                    $fieldPositions = $acroFields.GetFieldPositions($imageField.Key)
                    if ($fieldPositions.Count -gt 0) {
                        $rect = $fieldPositions[0].position
                        $image.SetAbsolutePosition($rect.Left, $rect.Bottom)
                        $image.ScaleToFit($rect.Width, $rect.Height)
                        $content = $stamper.GetOverContent($rect.Page)
                        $content.AddImage($image)
                    } else {
                        Write-Warning "Field position for '$($imageField.Key)' not found in the PDF."
                    }
                } else {
                    Write-Warning "Image path '$imagePath' is invalid or does not exist."
                }
            }
        }
        catch {
            # Handle any errors by throwing a terminating error.
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally {
            # Ensure the PdfStamper and PdfReader objects are closed to finalize the changes.
            $stamper.Close()
            $reader.Close()
        }
    }
}