# PowerShell-PDF
Creating PDF reports in PowerShell

### Installation
Download the files *PDF.psm1*, *iTextSharp.xml* and *iTextSharp.dll*. To create PDF files, you need to import the assembly, then import the PDF module. 

A sample script is provided. Run `.\kittens-report.ps1` to make a custom report (`kittens-report.pdf`). Edit the script to customize your PDF.

Note that you may need to right click on the files and select Properties -> Security -> Unblock if the assembly won't import.

### Example
This will create a PDF showing running processes:

    Add-Type -Path ".\itextsharp.dll"
    Import-Module ".\PDF.psm1"
    
    $pdf = New-Object iTextSharp.text.Document
    Create-PDF -Document $pdf -File "C:\processes-report.pdf" -TopMargin 20 -BottomMargin 20 -LeftMargin 20 -RightMargin 20 -Author "Patrick"
    $pdf.Open()
    Add-Title -Document $pdf -Text "Running processes at $(Get-Date)" -Centered
    $processes = @()
    Get-Process | foreach { $processes += $_.Name; $processes += "" + $_.Path }
    Add-Table -Document $pdf -Dataset $processes -Cols 2 -Centered
    $pdf.Close()

### Credits
This script relies on the .NET PDF creation library iTextSharp available from https://sourceforge.net/projects/itextsharp/

