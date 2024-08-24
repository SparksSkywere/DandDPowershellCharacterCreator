# Function to create a form with specific buttons and styles
function New-ProgramForm {
    param (
        [string]$Title,
        [int]$Width,
        [int]$Height,
        [string]$AcceptButtonText,
        [string]$SkipButtonText,
        [string]$CancelButtonText
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\Assets\installer.ico")
    $form.BackgroundImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\Assets\form_background.png")
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch

    $buttonPanel = New-Object System.Windows.Forms.Panel
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonPanel.Height = 50
    $form.Controls.Add($buttonPanel)

    $buttons = @(
        @{Text = $AcceptButtonText; DialogResult = [System.Windows.Forms.DialogResult]::OK},
        @{Text = $SkipButtonText; DialogResult = [System.Windows.Forms.DialogResult]::Ignore},
        @{Text = $CancelButtonText; DialogResult = [System.Windows.Forms.DialogResult]::Cancel}
    )

    $i = 0
    foreach ($button in $buttons) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Location = New-Object System.Drawing.Point([int]($i * 85), 10)
        $btn.Size = New-Object System.Drawing.Size(75, 30)
        $btn.Text = $button.Text
        $btn.DialogResult = $button.DialogResult
        $buttonPanel.Controls.Add($btn)
        $i++
    }

    return $form
}