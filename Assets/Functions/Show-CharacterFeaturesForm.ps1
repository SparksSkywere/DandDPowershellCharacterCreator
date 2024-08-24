# Function to display the character features form
function Show-CharacterFeaturesForm {
    Debug-Log "[Debug] Displaying Character Features Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $eyesControls = Set-ListBox -LabelText 'Select Eyes:' -X 10 -Y 20 -Width 110 -Height 170 -DataSource $EyesJSON -DisplayMember 'name'
    $hairControls = Set-ListBox -LabelText 'Select Hair:' -X 125 -Y 20 -Width 110 -Height 170 -DataSource $HairJSON -DisplayMember 'name'
    $skinControls = Set-ListBox -LabelText 'Select Skin:' -X 240 -Y 20 -Width 110 -Height 170 -DataSource $SkinJSON -DisplayMember 'name'

    $form.Controls.AddRange($eyesControls)
    $form.Controls.AddRange($hairControls)
    $form.Controls.AddRange($skinControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:Eyes = $eyesControls[1].SelectedItem.Name
        $global:Hair = $hairControls[1].SelectedItem.Name
        $global:Skin = $skinControls[1].SelectedItem.Name

        Debug-Log "Eyes: $($global:Eyes)"
        Debug-Log "Hair: $($global:Hair)"
        Debug-Log "Skin: $($global:Skin)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}