# Function to create list boxes dynamically
function Set-ListBox {
    param (
        [string]$LabelText,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [array]$DataSource,
        [string]$DisplayMember
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $label.Size = New-Object System.Drawing.Size($Width, 18)
    $label.Text = $LabelText
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + 25))
    $listBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $listBox.DataSource = [System.Collections.ArrayList]$DataSource
    $listBox.DisplayMember = $DisplayMember

    return @($label, $listBox)
}