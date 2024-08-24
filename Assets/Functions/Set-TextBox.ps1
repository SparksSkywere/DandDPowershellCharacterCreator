# Function to create text boxes dynamically
function Set-TextBox {
    param (
        [string]$LabelText,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$MaxLength,
        [string]$TooltipText = ""
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $label.Size = New-Object System.Drawing.Size($Width, 18)
    $label.Text = $LabelText
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + 25))
    $textBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $textBox.MaxLength = $MaxLength

    if ($TooltipText) {
        $toolTip = New-Object System.Windows.Forms.ToolTip
        $toolTip.SetToolTip($textBox, $TooltipText)
    }

    return @($label, $textBox)
}