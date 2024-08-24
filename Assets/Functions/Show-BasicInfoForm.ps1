# Function to display the basic information form
function Show-BasicInfoForm {
    Debug-Log "[Debug] Displaying Basic Info Form"

    # Create a new form with localized text
    $form = New-ProgramForm -Title $global:Localisation.FormTitle -Width 600 -Height 450 -AcceptButtonText $global:Localisation.AcceptButtonText -SkipButtonText $global:Localisation.SkipButtonText -CancelButtonText $global:Localisation.CancelButtonText

    # Create controls for Character Name
    $characterNameControls = Set-TextBox -LabelText $global:Localisation.CharacterNameLabel -X 10 -Y 20 -Width 200 -Height 20 -MaxLength 30

    # Create the Age controls
    $ageLabel = New-Object System.Windows.Forms.Label
    $ageLabel.Location = New-Object System.Drawing.Point(10, 75)
    $ageLabel.Size = New-Object System.Drawing.Size(110, 18)
    $ageLabel.Text = $global:Localisation.AgeLabel
    $ageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($ageLabel)

    $age = New-Object System.Windows.Forms.TextBox
    $age.Location = New-Object System.Drawing.Point(10, 95)
    $age.Size = New-Object System.Drawing.Size(58, 20)
    $age.MaxLength = 5

    $age.Add_TextChanged({
        if ($age.Text -match '\D') {
            $age.Text = $age.Text -replace '\D', ''
            $age.SelectionStart = $age.Text.Length
        }
    })

    # Create controls for the Player Name
    $playerNameControls = Set-TextBox -LabelText $global:Localisation.PlayerNameLabel -X 10 -Y 125 -Width 200 -Height 20 -MaxLength 30

    # Create the Browse Image controls
    $PlayerImageLabel = New-Object System.Windows.Forms.Label
    $PlayerImageLabel.Location = New-Object System.Drawing.Point(300, 275)
    $PlayerImageLabel.Size = New-Object System.Drawing.Size(180, 18)
    $PlayerImageLabel.Text = $global:Localisation.SelectImageLabel
    $PlayerImageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($PlayerImageLabel)

    # Create the "Browse" button to select an image
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Location = New-Object System.Drawing.Point(300, 300)
    $browseButton.Size = New-Object System.Drawing.Size(80, 30)
    $browseButton.Text = $global:Localisation.BrowseButtonText

    # PictureBox to display the selected image
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(300, 20)
    $pictureBox.Size = New-Object System.Drawing.Size(250, 250)
    $pictureBox.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage

    # Global flag to track if the user selected an image
    $global:ImageSelected = $false

    # Event handler for the Browse button click
    $browseButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Title = $global:Localisation.SelectImageLabel
        $openFileDialog.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp"

        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $global:CharacterImage = $openFileDialog.FileName
            $pictureBox.Image = [System.Drawing.Image]::FromFile($global:CharacterImage)
            $global:ImageSelected = $true
            Debug-Log "[Debug] Internal-Path = $global:ImageSelected"
        }
    })

    # Add controls to the form
    $form.Controls.AddRange($characterNameControls)
    $form.Controls.Add($age)
    $form.Controls.Add($PlayerImageLabel)
    $form.Controls.AddRange($playerNameControls)
    $form.Controls.Add($browseButton)
    $form.Controls.Add($pictureBox)

    # Display the form
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    # Capture the values from the form controls
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:WrittenCharactername = $characterNameControls[1].Text
        $global:WrittenAge = $age.Text
        $global:WrittenPlayername = $playerNameControls[1].Text

        Debug-Log "`n[Debug] Character Name Captured: $($global:WrittenCharactername)"
        Debug-Log "[Debug] Age Captured: $($global:WrittenAge)"
        Debug-Log "[Debug] Player Name Captured: $($global:WrittenPlayername)"
        Debug-Log "[Debug] Internal check: $ImageSelected"
        Debug-Log "[Debug] Character Image Selected: $($global:CharacterImage)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}