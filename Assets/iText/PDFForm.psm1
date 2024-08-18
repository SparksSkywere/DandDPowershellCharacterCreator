# PDFForm.psm1
# This module contains functions for working with PDF forms using the iTextSharp library.

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
                throw "iTextSharp library not found at [$localLibraryPath]. Please ensure itextsharp.dll is present in the script directory."
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
                $acroFields.SetField($field.Key, $field.Value) | Out-Null
            }

            # Insert images into specified fields in the PDF.
            foreach ($imageField in $ImageFields.GetEnumerator()) {
                $imagePath = $imageField.Value
                Write-Verbose "Processing image for field: $($imageField.Key) with path: $imagePath"
            
                if (Test-Path -Path $imagePath -PathType Leaf) {
                    try {
                        Write-Host "Attempting to insert image at path: $imagePath into field: $($imageField.Key)"
                        $image = [iTextSharp.text.Image]::GetInstance($imagePath)
                        $fieldPositions = $acroFields.GetFieldPositions($imageField.Key)
                        
                        if ($fieldPositions -and $fieldPositions.Count -gt 0) {
                            $rect = $fieldPositions[0].position
                            Write-Host "Field position details: Page=$($fieldPositions[0].Page), Left=$($rect.Left), Bottom=$($rect.Bottom)"
                    
                            $pageNumber = $fieldPositions[0].Page
                    
                            if ($null -eq $pageNumber -or $pageNumber -eq 0) {
                                throw "Invalid or missing page number for field '$($imageField.Key)'."
                            }
                    
                            $content = $stamper.GetOverContent($pageNumber)
                            
                            if ($null -eq $content) {
                                throw "Unable to get content layer for page $pageNumber."
                            }
                            
                            $image.SetAbsolutePosition($rect.Left, $rect.Bottom)
                            $image.ScaleToFit($rect.Width, $rect.Height)
                            $content.AddImage($image)
                        } else {
                            throw "Field positions for image field '$($imageField.Key)' not found in the PDF."
                        }
                    } catch {
                        Write-Host "Error encountered while processing image field '$($imageField.Key)': $($_.Exception.Message)"
                        throw "Error while processing image field '$($imageField.Key)': $($_.Exception.Message)"
                    }                                     
                } else {
                    throw "Image file not found: $imagePath"
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

# Export functions to make them available when the module is imported.
Export-ModuleMember -Function Find-ITextSharpLibrary, Get-PdfFieldNames, Save-PdfField